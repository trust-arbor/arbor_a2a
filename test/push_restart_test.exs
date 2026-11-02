defmodule Arbor.A2A.PushRestartTest do
  use ExUnit.Case, async: false
  alias Arbor.A2A.{Error, Events, Push, Server, Task, TaskStore, TestAgent, TestSupport}

  test "dispatcher restart resumes existing outboxes without another store write" do
    owner = self()

    receiver =
      start_supervised!(
        {Bandit,
         plug: fn conn, _ ->
           {:ok, bytes, conn} = Plug.Conn.read_body(conn)
           send(owner, {:notification, Jason.decode!(bytes)})
           Plug.Conn.send_resp(conn, 204, "")
         end,
         port: 0,
         ip: {127, 0, 0, 1}}
      )

    {:ok, {_, port}} = ThousandIsland.listener_info(receiver)

    policy = fn _ ->
      if self() == owner do
        {:ok, {127, 0, 0, 1}}
      else
        send(owner, {:delivery_worker, self()})

        receive do
          :continue -> {:ok, {127, 0, 0, 1}}
        after
          5000 -> {:error, :untrusted_destination}
        end
      end
    end

    {:ok, store} = TaskStore.start_link()
    card = put_in(TestSupport.card(), ["capabilities", "pushNotifications"], true)

    {:ok, server} =
      Server.new(handler: TestAgent, store: store, card: card, push: [destination_policy: policy])

    task = Task.new("ctx")
    :ok = TaskStore.put(store, {:alice, nil}, task)

    {:ok, _} =
      Server.dispatch(
        server,
        "CreateTaskPushNotificationConfig",
        %{"taskId" => task["id"], "url" => "http://127.0.0.1:#{port}/"},
        :alice
      )

    :ok =
      TaskStore.put(
        store,
        {:alice, nil},
        put_in(task, ["status", "state"], "TASK_STATE_COMPLETED")
      )

    assert_receive {:delivery_worker, old_worker}, 3000
    on_exit(fn -> Process.exit(old_worker, :kill) end)
    dispatcher = Process.whereis(Push)
    monitor = Process.monitor(dispatcher)
    Process.exit(dispatcher, :kill)
    assert_receive {:DOWN, ^monitor, :process, ^dispatcher, _}, 3000
    assert_receive {:delivery_worker, new_worker}, 3000
    on_exit(fn -> Process.exit(new_worker, :kill) end)
    assert old_worker != new_worker
    Process.exit(old_worker, :kill)
    send(new_worker, :continue)
    assert_receive {:notification, %{"task" => %{"id" => id}}}, 3000
    assert id == task["id"]
  end

  test "subscription capacity returns a typed error without crashing storage" do
    {:ok, store} = TaskStore.start_link()
    task = Task.new("ctx")
    :ok = TaskStore.put(store, :alice, task)

    {refs, error} =
      Enum.reduce_while(1..1001, {[], nil}, fn _, {refs, _} ->
        case TaskStore.subscribe(store, :alice, task["id"]) do
          {:ok, ref} -> {:cont, {[ref | refs], nil}}
          {:error, error} -> {:halt, {refs, error}}
        end
      end)

    Enum.each(refs, &Events.close/1)
    assert %Error{code: -32_603} = error
    assert Process.alive?(store)
  end
end
