defmodule Arbor.A2A.ExecutionTest do
  use ExUnit.Case, async: false
  alias Arbor.A2A.{Server, Task, TaskStore, TestSupport}

  defmodule Agent do
    @behaviour Arbor.A2A.Server.Handler
    def handle_message(params, _context) do
      {:async,
       fn context ->
         owner = Process.whereis(Arbor.A2A.ExecutionTest.Observer)
         send(owner, {:worker, self(), context.task_id})
         if hd(params["message"]["parts"])["text"] == "crash", do: raise("private reason")
         receive do: (:finish -> :ok)

         {:ok,
          %{
            "task" =>
              Task.new(context.context_id, id: context.task_id, state: "TASK_STATE_COMPLETED")
          }}
       end}
    end
  end

  setup do
    Process.register(self(), __MODULE__.Observer)
    {server, store} = TestSupport.server(timeout: 2000)
    %{server: %{server | handler: Agent}, store: store}
  end

  test "returnImmediately acknowledges managed work and cancellation stops it", %{
    server: server,
    store: store
  } do
    params = Map.put(TestSupport.params(), "configuration", %{"returnImmediately" => true})
    assert {:ok, %{"task" => task}} = Server.dispatch(server, "SendMessage", params)
    assert task["status"]["state"] == "TASK_STATE_SUBMITTED"
    assert_receive {:worker, pid, id}
    assert task["id"] == id
    monitor = Process.monitor(pid)

    assert {:ok, %{"status" => %{"state" => "TASK_STATE_CANCELED"}}} =
             Server.dispatch(server, "CancelTask", %{"id" => id})

    assert_receive {:DOWN, ^monitor, :process, ^pid, _}

    assert {:ok, %{"status" => %{"state" => "TASK_STATE_CANCELED"}}} =
             TaskStore.get(store, {:anonymous, nil}, id)
  end

  test "blocking sends wait for managed completion", %{server: server} do
    caller =
      Elixir.Task.async(fn -> Server.dispatch(server, "SendMessage", TestSupport.params()) end)

    assert_receive {:worker, pid, _}
    send(pid, :finish)

    assert {:ok, %{"task" => %{"status" => %{"state" => "TASK_STATE_COMPLETED"}}}} =
             Elixir.Task.await(caller)
  end

  test "managed crashes become failed tasks without private error details", %{server: server} do
    assert {:ok, %{"task" => %{"status" => %{"state" => "TASK_STATE_FAILED"}}}} =
             Server.dispatch(server, "SendMessage", TestSupport.params("crash"))
  end

  @tag :tmp_dir
  test "restart fails abandoned managed work without replay", %{tmp_dir: dir} do
    opts = [persistence: {TaskStore.File, Path.join(dir, "tasks")}]
    {:ok, store} = TaskStore.start_link(opts)
    task = Task.new("context")
    :ok = TaskStore.put_managed(store, :alice, task)
    GenServer.stop(store)
    {:ok, restarted} = TaskStore.start_link(opts)

    assert {:ok, %{"status" => %{"state" => "TASK_STATE_FAILED"}}} =
             TaskStore.get(restarted, :alice, task["id"])
  end
end
