defmodule Arbor.A2A.PushTest do
  use ExUnit.Case, async: true
  alias Arbor.A2A.{DestinationPolicy, Message, Push, Server, Task, TaskStore, TestSupport}

  test "owned webhook configs deliver authenticated updates and enforce access" do
    owner = self()

    pid =
      start_supervised!(
        {Bandit,
         plug: fn conn, _ ->
           {:ok, bytes, conn} = Plug.Conn.read_body(conn)

           send(
             owner,
             {:delivery, Plug.Conn.get_req_header(conn, "authorization"), Jason.decode!(bytes)}
           )

           Plug.Conn.send_resp(conn, 204, "")
         end,
         port: 0,
         ip: {127, 0, 0, 1}}
      )

    {:ok, {_, port}} = ThousandIsland.listener_info(pid)
    {server, store} = TestSupport.server()

    server = %{
      server
      | card: put_in(server.card, ["capabilities", "pushNotifications"], true),
        push: [destination_policy: fn _ -> {:ok, {127, 0, 0, 1}} end]
    }

    task = Task.new("ctx", state: "TASK_STATE_WORKING")
    :ok = TaskStore.put(store, {:alice, nil}, task)

    config = %{
      "taskId" => task["id"],
      "url" => "http://127.0.0.1:#{port}/webhook",
      "authentication" => %{"scheme" => "Bearer", "credentials" => "fixture-only"}
    }

    assert {:ok, created} =
             Server.dispatch(server, "CreateTaskPushNotificationConfig", config, :alice)

    assert Message.nonempty?(created["id"])

    assert {:error, _} =
             Server.dispatch(
               server,
               "GetTaskPushNotificationConfig",
               Map.take(created, ["id", "taskId"]),
               :bob
             )

    assert {:ok, %{"configs" => [^created]}} =
             Server.dispatch(
               server,
               "ListTaskPushNotificationConfigs",
               %{"taskId" => task["id"]},
               :alice
             )

    :ok =
      TaskStore.put(
        store,
        {:alice, nil},
        put_in(task, ["status", "state"], "TASK_STATE_COMPLETED")
      )

    assert_receive {:delivery, ["Bearer fixture-only"], %{"task" => %{"id" => id}}}, 3000
    assert id == task["id"]

    assert {:ok, %{}} =
             Server.dispatch(
               server,
               "DeleteTaskPushNotificationConfig",
               Map.take(created, ["id", "taskId"]),
               :alice
             )

    assert {:ok, %{"configs" => []}} =
             Server.dispatch(
               server,
               "ListTaskPushNotificationConfigs",
               %{"taskId" => task["id"]},
               :alice
             )
  end

  test "default webhook policy refuses nonpublic destinations and credential injection" do
    for ip <- [
          {127, 0, 0, 1},
          {10, 1, 2, 3},
          {169, 254, 169, 254},
          {100, 64, 0, 1},
          {192, 0, 2, 1},
          {198, 51, 100, 1},
          {0, 0, 0, 0, 0, 0, 0, 1}
        ] do
      refute DestinationPolicy.public?(ip)
    end

    assert DestinationPolicy.public?({8, 8, 8, 8})
    assert {:error, _} = DestinationPolicy.resolve("https://127.0.0.1/webhook")

    assert {:error, _} =
             Push.validate(
               %{
                 "url" => "http://127.0.0.1",
                 "authentication" => %{
                   "scheme" => "Bearer",
                   "credentials" => "x\r\nheader: secret"
                 }
               },
               destination_policy: fn _ -> {:ok, {127, 0, 0, 1}} end
             )
  end
end
