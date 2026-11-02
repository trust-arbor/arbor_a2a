defmodule Arbor.A2A.StreamingTest do
  use ExUnit.Case, async: true
  alias Arbor.A2A.{Client, Events, HttpPlug, Message, Server, Task, TaskStore, TestSupport}

  defmodule Agent do
    @behaviour Arbor.A2A.Server.Handler
    def handle_message(params, context) do
      if hd(params["message"]["parts"])["text"] == "direct" do
        {:ok,
         %{"message" => Message.text("hello", role: "ROLE_AGENT", context_id: context.context_id)}}
      else
        task = Task.new(context.context_id, id: context.task_id, state: "TASK_STATE_WORKING")
        :ok = Server.emit(context, %{"task" => task})

        :ok =
          Server.emit(context, %{
            "artifactUpdate" => %{
              "taskId" => context.task_id,
              "contextId" => context.context_id,
              "artifact" => %{"artifactId" => "a", "parts" => [%{"text" => "first"}]}
            }
          })

        :ok =
          Server.emit(context, %{
            "artifactUpdate" => %{
              "taskId" => context.task_id,
              "contextId" => context.context_id,
              "append" => true,
              "artifact" => %{"artifactId" => "a", "parts" => [%{"text" => "second"}]}
            }
          })

        {:ok, stored} = TaskStore.get(context.store, context.partition, context.task_id)
        {:ok, %{"task" => put_in(stored, ["status", "state"], "TASK_STATE_COMPLETED")}}
      end
    end
  end

  test "real HTTP delivers task, artifact deltas and terminal state in order" do
    {base, server} = live_server()
    {:ok, client} = Client.new(base <> "/a2a")

    assert {:ok, events} =
             Client.stream(
               client,
               "SendStreamingMessage",
               %{"message" => Message.text("work")},
               [],
               fn value, acc -> {:cont, acc ++ [value]} end
             )

    assert [%{"task" => task} | updates] = events
    assert List.last(updates)["statusUpdate"]["status"]["state"] == "TASK_STATE_COMPLETED"
    assert Enum.count(updates, &Map.has_key?(&1, "artifactUpdate")) == 2
    assert {:ok, stored} = TaskStore.get(server.store, {:anonymous, nil}, task["id"])
    assert Enum.map(hd(stored["artifacts"])["parts"], & &1["text"]) == ["first", "second"]
  end

  test "direct message streams have one event" do
    {base, _} = live_server()
    {:ok, client} = Client.new(base <> "/a2a")

    assert {:ok, [%{"message" => _}]} =
             Client.stream(
               client,
               "SendStreamingMessage",
               %{"message" => Message.text("direct")},
               [],
               fn e, acc -> {:cont, [e | acc]} end
             )
  end

  test "subscriptions are atomic snapshots and isolated by principal" do
    {server, store} = TestSupport.server()
    task = Task.new("ctx")
    :ok = TaskStore.put(store, {:alice, nil}, task)
    assert {:error, _} = TaskStore.subscribe(store, {:bob, nil}, task["id"])
    assert {:ok, ref} = TaskStore.subscribe(store, {:alice, nil}, task["id"])
    assert {:ok, %{"task" => ^task}} = Events.next(ref)

    :ok =
      TaskStore.put(
        store,
        {:alice, nil},
        put_in(task, ["status", "state"], "TASK_STATE_COMPLETED")
      )

    assert {:ok, %{"statusUpdate" => _}} = Events.next(ref)
    assert :done = Events.next(ref)
    assert {:error, _} = Server.stream(server, "SubscribeToTask", %{"id" => task["id"]})
  end

  test "bounded slow consumers fail without losing authoritative task state" do
    {_, store} = TestSupport.server()
    task = Task.new("ctx")
    :ok = TaskStore.put(store, :owner, task)
    {:ok, ref} = TaskStore.subscribe(store, :owner, task["id"])

    for i <- 1..70 do
      :ok = TaskStore.put(store, :owner, Map.put(task, "metadata", %{"sequence" => i}))
    end

    assert {:error, :slow_consumer} = Events.next(ref)
    assert {:ok, %{"metadata" => %{"sequence" => 70}}} = TaskStore.get(store, :owner, task["id"])
  end

  defp live_server do
    {:ok, store} = TaskStore.start_link()
    card = put_in(TestSupport.card(), ["capabilities", "streaming"], true)
    {:ok, server} = Server.new(handler: Agent, store: store, card: card)

    pid =
      start_supervised!({Bandit, plug: {HttpPlug, server: server}, port: 0, ip: {127, 0, 0, 1}})

    {:ok, {_, port}} = ThousandIsland.listener_info(pid)
    {"http://127.0.0.1:#{port}", server}
  end
end
