defmodule Arbor.A2A.TaskStoreTest do
  use ExUnit.Case, async: true
  alias Arbor.A2A.{Error, Message, Task, TaskStore}

  setup do
    store = start_supervised!(TaskStore)
    %{store: store}
  end

  @tag :timestamp_precision
  test "nanosecond timestamps preserve descending order and cursor boundaries", %{store: store} do
    for {id, stamp} <- [
          {"a", "2026-11-01T00:00:00.1234567Z"},
          {"z", "2026-11-01T00:00:00.1234568Z"}
        ] do
      :ok =
        TaskStore.put(
          store,
          :alice,
          Task.new("ctx", id: id) |> put_in(["status", "timestamp"], stamp)
        )
    end

    assert {:ok, %{"tasks" => [%{"id" => "z"}], "nextPageToken" => token}} =
             TaskStore.list(store, :alice, %{"pageSize" => 1})

    assert {:ok, %{"tasks" => [%{"id" => "a"}]}} =
             TaskStore.list(store, :alice, %{"pageSize" => 1, "pageToken" => token})
  end

  @tag :timestamp_precision
  test "timestamp-after filtering never rounds an older nanosecond into the result", %{
    store: store
  } do
    old =
      Task.new("ctx", id: "old")
      |> put_in(["status", "timestamp"], "2026-11-01T00:00:00.1234567Z")

    :ok = TaskStore.put(store, :alice, old)

    assert {:ok, %{"tasks" => []}} =
             TaskStore.list(store, :alice, %{
               "statusTimestampAfter" => "2026-11-01T00:00:00.1234568Z"
             })
  end

  @tag :list_review
  test "ListTasks sorts by actual status time descending and pages through that order", %{
    store: store
  } do
    old = Task.new("ctx", id: "a") |> put_in(["status", "timestamp"], "2026-11-01T00:00:00Z")

    newer =
      Task.new("ctx", id: "z") |> put_in(["status", "timestamp"], "2026-11-01T03:00:00+01:00")

    :ok = TaskStore.put(store, :alice, old)
    :ok = TaskStore.put(store, :alice, newer)

    assert {:ok, %{"tasks" => [%{"id" => "z"}], "nextPageToken" => token}} =
             TaskStore.list(store, :alice, %{"pageSize" => 1})

    assert {:ok, %{"tasks" => [%{"id" => "a"}], "nextPageToken" => ""}} =
             TaskStore.list(store, :alice, %{"pageSize" => 1, "pageToken" => token})
  end

  @tag :list_review
  test "includeArtifacts true explicitly represents no artifacts as an empty array", %{
    store: store
  } do
    :ok = TaskStore.put(store, :alice, Task.new("ctx", id: "empty"))

    assert {:ok, %{"tasks" => [%{"artifacts" => []}]}} =
             TaskStore.list(store, :alice, %{"includeArtifacts" => true})

    assert {:ok, %{"tasks" => [omitted]}} = TaskStore.list(store, :alice)
    refute Map.has_key?(omitted, "artifacts")
  end

  test "same task ID is partitioned by tenant and principal", %{store: store} do
    task = Task.new("ctx", id: "id")
    :ok = TaskStore.put(store, {:alice, "one"}, task)
    assert {:ok, ^task} = TaskStore.get(store, {:alice, "one"}, "id")

    for partition <- [{:bob, "one"}, {:alice, "two"}, {:anonymous, "one"}] do
      assert {:error, %Error{code: -32_001}} = TaskStore.get(store, partition, "id")
    end
  end

  test "signed pagination is caller and filter bound and rejects tampering", %{store: store} do
    for id <- ~w(a b c),
        do:
          TaskStore.put(
            store,
            :alice,
            Task.new("ctx", id: id) |> put_in(["status", "timestamp"], "2026-11-01T00:00:00Z")
          )

    assert {:ok, %{"tasks" => [%{"id" => "a"}], "nextPageToken" => next, "totalSize" => 3}} =
             TaskStore.list(store, :alice, %{"pageSize" => 1})

    assert {:ok, %{"tasks" => [%{"id" => "b"}]}} =
             TaskStore.list(store, :alice, %{"pageSize" => 1, "pageToken" => next})

    for {owner, params} <- [
          {:bob, %{"pageSize" => 1, "pageToken" => next}},
          {:alice, %{"pageSize" => 2, "pageToken" => next}},
          {:alice, %{"pageSize" => 1, "pageToken" => next <> "x"}},
          {:alice, %{"pageToken" => String.duplicate("a", 3000)}}
        ] do
      assert {:error, %Error{code: -32_602}} = TaskStore.list(store, owner, params)
    end
  end

  test "filters, history and artifact projections preserve storage", %{store: store} do
    task =
      Task.new("ctx",
        id: "one",
        state: "TASK_STATE_COMPLETED",
        history: [Message.text("first"), Message.text("last")]
      )
      |> Map.put("artifacts", [%{"artifactId" => "a", "parts" => [%{"text" => "result"}]}])

    :ok = TaskStore.put(store, :alice, task)
    :ok = TaskStore.put(store, :alice, Task.new("other", id: "two"))

    assert {:ok, %{"tasks" => [projected]}} =
             TaskStore.list(store, :alice, %{
               "contextId" => "ctx",
               "status" => "TASK_STATE_COMPLETED",
               "historyLength" => 1
             })

    refute Map.has_key?(projected, "artifacts")
    assert length(projected["history"]) == 1

    assert {:ok, %{"tasks" => [full]}} =
             TaskStore.list(store, :alice, %{"contextId" => "ctx", "includeArtifacts" => true})

    assert full == task
  end

  for params <- [
        %{"pageSize" => 0},
        %{"pageSize" => 101},
        %{"pageSize" => "1"},
        %{"historyLength" => -1},
        %{"status" => "completed"},
        %{"statusTimestampAfter" => "bad"},
        %{"includeArtifacts" => "yes"},
        %{"pageToken" => nil}
      ] do
    test "invalid list filter #{inspect(params)} returns invalid params", %{store: store} do
      assert {:error, %Error{code: -32_602}} =
               TaskStore.list(store, :alice, unquote(Macro.escape(params)))

      assert {:ok, %{"tasks" => []}} = TaskStore.list(store, :alice)
    end
  end

  test "terminal tasks cannot regress or change their context", %{store: store} do
    task = Task.new("ctx", id: "id", state: "TASK_STATE_COMPLETED")
    :ok = TaskStore.put(store, :alice, task)
    assert :ok = TaskStore.put(store, :alice, task)
    assert {:error, %Error{}} = TaskStore.put(store, :alice, Task.new("ctx", id: "id"))
    assert {:error, %Error{}} = TaskStore.put(store, :alice, %{task | "contextId" => "other"})
    assert {:ok, ^task} = TaskStore.get(store, :alice, "id")
  end

  test "cancel and update race cannot resurrect a canceled task", %{store: store} do
    task = Task.new("ctx", id: "id")
    :ok = TaskStore.put(store, :alice, task)
    assert {:ok, canceled} = TaskStore.cancel(store, :alice, "id")
    assert {:error, %Error{}} = TaskStore.put(store, :alice, task)
    assert {:ok, ^canceled} = TaskStore.get(store, :alice, "id")
  end

  test "capacity and task byte limits reject admission" do
    {:ok, store} = TaskStore.start_link(max_tasks: 1, max_task_bytes: 500)
    on_exit(fn -> if Process.alive?(store), do: GenServer.stop(store) end)
    assert :ok = TaskStore.put(store, :alice, Task.new("ctx", id: "first"))
    assert {:error, %Error{}} = TaskStore.put(store, :alice, Task.new("ctx", id: "second"))

    oversized =
      Map.put(Task.new("ctx", id: "first"), "metadata", %{"huge" => String.duplicate("x", 501)})

    assert {:error, %Error{}} = TaskStore.put(store, :alice, oversized)
    assert {:ok, %{"id" => "first"}} = TaskStore.get(store, :alice, "first")
  end

  test "expiration removes access and frees capacity" do
    {:ok, store} = TaskStore.start_link(ttl_ms: 5, max_tasks: 1)
    :ok = TaskStore.put(store, :alice, Task.new("ctx", id: "old"))
    Process.sleep(10)
    assert {:error, %Error{code: -32_001}} = TaskStore.get(store, :alice, "old")
    assert :ok = TaskStore.put(store, :alice, Task.new("ctx", id: "new"))
  end
end
