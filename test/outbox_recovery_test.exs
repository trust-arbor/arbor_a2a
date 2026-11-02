defmodule Arbor.A2A.OutboxRecoveryTest do
  use ExUnit.Case, async: true
  alias Arbor.A2A.{Server, Task, TaskStore, TestSupport}
  @tag :tmp_dir
  test "an unacknowledged authenticated webhook survives store restart", %{tmp_dir: dir} do
    owner = self()

    receiver =
      start_supervised!(
        {Bandit,
         plug: fn conn, _ ->
           {:ok, bytes, conn} = Plug.Conn.read_body(conn)

           send(
             owner,
             {:recovered_delivery, Plug.Conn.get_req_header(conn, "authorization"),
              Jason.decode!(bytes)}
           )

           Plug.Conn.send_resp(conn, 204, "")
         end,
         port: 0,
         ip: {127, 0, 0, 1}}
      )

    {:ok, {_, port}} = ThousandIsland.listener_info(receiver)

    policy = fn _ ->
      if self() != owner do
        send(owner, {:paused_delivery, self()})
        receive do: (:continue -> :ok)
      end

      {:ok, {127, 0, 0, 1}}
    end

    path = Path.join(dir, "tasks.snapshot")
    {:ok, store} = TaskStore.start_link(persistence: {TaskStore.File, path})
    card = put_in(TestSupport.card(), ["capabilities", "pushNotifications"], true)

    {:ok, server} =
      Server.new(
        handler: Arbor.A2A.TestAgent,
        store: store,
        card: card,
        push: [destination_policy: policy]
      )

    task = Task.new("ctx")
    :ok = TaskStore.put(store, {:alice, nil}, task)

    config = %{
      "taskId" => task["id"],
      "url" => "http://127.0.0.1:#{port}/webhook",
      "authentication" => %{"scheme" => "Bearer", "credentials" => "fixture"}
    }

    {:ok, saved} = Server.dispatch(server, "CreateTaskPushNotificationConfig", config, :alice)

    :ok =
      TaskStore.put(
        store,
        {:alice, nil},
        put_in(task, ["status", "state"], "TASK_STATE_COMPLETED")
      )

    assert_receive {:paused_delivery, worker}, 3000
    GenServer.stop(store)
    Process.exit(worker, :kill)

    {:ok, recovered} =
      TaskStore.start_link(
        persistence: {TaskStore.File, path},
        push_options: [destination_policy: fn _ -> {:ok, {127, 0, 0, 1}} end]
      )

    assert_receive {:recovered_delivery, ["Bearer fixture"], %{"task" => %{"id" => id}}}, 3000
    assert id == task["id"]

    assert {:ok, ^saved} =
             TaskStore.push(
               recovered,
               {:alice, nil},
               "GetTaskPushNotificationConfig",
               Map.take(saved, ["id", "taskId"]),
               []
             )
  end
end
