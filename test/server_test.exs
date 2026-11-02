defmodule Arbor.A2A.ServerTest do
  use ExUnit.Case, async: true
  alias Arbor.A2A.{Error, Message, Server}
  import Arbor.A2A.TestSupport

  setup do
    {server, store} = server()
    on_exit(fn -> if Process.alive?(store), do: GenServer.stop(store) end)
    %{server: server, store: store}
  end

  test "send, get and list preserve the task, history, context and principal", %{server: server} do
    assert {:ok, %{"task" => task}} = Server.dispatch(server, "SendMessage", params(), :alice)
    assert task["status"]["state"] == "TASK_STATE_COMPLETED"
    assert {:ok, ^task} = Server.dispatch(server, "GetTask", %{"id" => task["id"]}, :alice)

    assert {:error, %Error{code: -32_001}} =
             Server.dispatch(server, "GetTask", %{"id" => task["id"]}, :bob)

    assert {:ok, %{"tasks" => [^task], "totalSize" => 1}} =
             Server.dispatch(server, "ListTasks", %{}, :alice)

    assert {:ok, %{"tasks" => []}} = Server.dispatch(server, "ListTasks", %{}, :bob)
    assert length(task["history"]) == 2
  end

  test "direct replies have no task", %{server: server} do
    assert {:ok, %{"message" => message}} =
             Server.dispatch(server, "SendMessage", params("direct"))

    assert message["role"] == "ROLE_AGENT"
    assert is_binary(message["contextId"])
    assert {:ok, %{"tasks" => []}} = Server.dispatch(server, "ListTasks", %{})
  end

  test "interrupted tasks can resume and inherit context", %{server: server} do
    assert {:ok, %{"task" => first}} = Server.dispatch(server, "SendMessage", params("input"))
    assert first["status"]["state"] == "TASK_STATE_INPUT_REQUIRED"
    message = Message.text("continue", task_id: first["id"])

    assert {:ok, %{"task" => second}} =
             Server.dispatch(server, "SendMessage", %{"message" => message})

    assert second["id"] == first["id"]
    assert second["contextId"] == first["contextId"]
    assert length(second["history"]) == 4

    assert {:error, %Error{code: -32_004}} =
             Server.dispatch(server, "SendMessage", %{"message" => message})
  end

  test "conflicting contexts and inaccessible tasks are rejected before handler", %{
    server: server
  } do
    {:ok, %{"task" => task}} = Server.dispatch(server, "SendMessage", params("input"), :alice)

    assert {:error, %Error{code: -32_602}} =
             Server.dispatch(
               server,
               "SendMessage",
               %{"message" => Message.text("continue", task_id: task["id"], context_id: "other")},
               :alice
             )

    assert {:error, %Error{code: -32_001}} =
             Server.dispatch(
               server,
               "SendMessage",
               %{"message" => Message.text("continue", task_id: task["id"])},
               :bob
             )
  end

  test "nonblocking acknowledgement can be canceled atomically", %{server: server} do
    p = Map.put(params(), "configuration", %{"returnImmediately" => true})
    assert {:ok, %{"task" => task}} = Server.dispatch(server, "SendMessage", p)
    assert {:ok, canceled} = Server.dispatch(server, "CancelTask", %{"id" => task["id"]})
    assert canceled["status"]["state"] == "TASK_STATE_CANCELED"

    assert {:error, %Error{code: -32_002}} =
             Server.dispatch(server, "CancelTask", %{"id" => task["id"]})
  end

  for method <- ~w(SendStreamingMessage SubscribeToTask GetExtendedAgentCard) do
    test "unimplemented optional #{method} fails explicitly", %{server: server} do
      assert {:error, %Error{code: -32_004}} = Server.dispatch(server, unquote(method), %{})
    end
  end

  for method <-
        ~w(CreateTaskPushNotificationConfig GetTaskPushNotificationConfig ListTaskPushNotificationConfigs DeleteTaskPushNotificationConfig) do
    test "push capability #{method} is not advertised or accepted", %{server: server} do
      assert {:error, %Error{code: -32_003}} = Server.dispatch(server, unquote(method), %{})
    end
  end

  test "invalid content, params and unknown methods have canonical errors", %{server: server} do
    assert {:error, %Error{code: -32_005}} =
             Server.dispatch(server, "SendMessage", %{
               "message" => %{
                 Message.text("x")
                 | "parts" => [%{"raw" => "AA==", "mediaType" => "image/png"}]
               }
             })

    assert {:error, %Error{code: -32_602}} =
             Server.dispatch(server, "SendMessage", %{"message" => nil})

    assert {:error, %Error{code: -32_602}} =
             Server.dispatch(server, "GetTask", %{"id" => "id", "historyLength" => -1})

    assert {:error, %Error{code: -32_601}} = Server.dispatch(server, "message/send", %{})

    assert {:error, %Error{code: -32_006}} =
             Server.dispatch(server, "SendMessage", params("invalid"))
  end

  test "history limit does not truncate stored history", %{server: server} do
    assert {:ok, %{"task" => task}} =
             Server.dispatch(
               server,
               "SendMessage",
               Map.put(params(), "configuration", %{"historyLength" => 0})
             )

    refute Map.has_key?(task, "history")
    assert {:ok, full} = Server.dispatch(server, "GetTask", %{"id" => task["id"]})
    assert length(full["history"]) == 2

    assert {:ok, limited} =
             Server.dispatch(server, "GetTask", %{"id" => task["id"], "historyLength" => 1})

    assert length(limited["history"]) == 1
  end

  test "callback deadline is finite and worker is reaped", %{server: server} do
    assert {:error, %Error{code: -32_603}} =
             Server.dispatch(%{server | timeout: 20}, "SendMessage", params("timeout"))
  end

  test "tenant routing is separate from caller identity", %{server: server} do
    server = %{server | tenant: "tenant-a"}
    assert {:error, %Error{code: -32_602}} = Server.dispatch(server, "ListTasks", %{})

    assert {:ok, %{"tasks" => []}} =
             Server.dispatch(server, "ListTasks", %{"tenant" => "tenant-a"})
  end

  test "cannot advertise unsupported capabilities", %{server: server} do
    opts = Map.from_struct(server) |> Map.to_list()

    assert {:error, :invalid_server_config} =
             Server.new(
               Keyword.put(opts, :card, put_in(server.card, ["capabilities", "streaming"], true))
             )
  end
end
