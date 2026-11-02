defmodule Arbor.A2A.PersistenceTest do
  use ExUnit.Case, async: true
  alias Arbor.A2A.{Task, TaskStore}
  @tag :tmp_dir
  test "private atomic snapshots survive restarts with principal isolation", %{tmp_dir: dir} do
    path = Path.join(dir, "tasks.snapshot")
    opts = [persistence: {TaskStore.File, path}]
    {:ok, store} = TaskStore.start_link(opts)
    task = Task.new("context")
    :ok = TaskStore.put(store, {"alice", "tenant"}, task)
    assert {:ok, %{mode: mode}} = File.stat(path)
    assert Bitwise.band(mode, 0o777) == 0o600
    GenServer.stop(store)
    {:ok, recovered} = TaskStore.start_link(opts)
    assert {:ok, ^task} = TaskStore.get(recovered, {"alice", "tenant"}, task["id"])
    assert {:error, _} = TaskStore.get(recovered, {"bob", "tenant"}, task["id"])
  end

  defmodule FailingAdapter do
    @behaviour TaskStore.Persistence
    def load(_), do: {:ok, nil}
    def save(_, _), do: {:error, :unavailable}
  end

  test "failed durable commit does not change memory or publish an update" do
    {:ok, store} = TaskStore.start_link(persistence: {FailingAdapter, nil})
    task = Task.new("context")
    assert {:error, _} = TaskStore.put(store, :owner, task)
    assert {:error, _} = TaskStore.get(store, :owner, task["id"])
  end
end
