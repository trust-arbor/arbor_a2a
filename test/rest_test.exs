defmodule Arbor.A2A.RestTest do
  use ExUnit.Case, async: true
  import Plug.Test
  import Plug.Conn
  alias Arbor.A2A.{Message, RestPlug, Task, TaskStore, TestSupport}

  test "REST dispatch shares task semantics and typed error mappings" do
    {server, _} = TestSupport.server()
    opts = RestPlug.init(server: server, path: "/rest")
    response = request(:post, "/rest/message:send", %{"message" => Message.text("hello")}, opts)
    assert response.status == 200
    task = Jason.decode!(response.resp_body)["task"]
    get = request(:get, "/rest/tasks/#{task["id"]}?historyLength=0", nil, opts)
    assert get.status == 200
    refute Map.has_key?(Jason.decode!(get.resp_body), "history")
    missing = request(:get, "/rest/tasks/missing", nil, opts)
    assert missing.status == 404
    assert hd(Jason.decode!(missing.resp_body)["error"]["details"])["reason"] == "TASK_NOT_FOUND"
    list = request(:get, "/rest/tasks?pageSize=1&includeArtifacts=true", nil, opts)
    assert hd(Jason.decode!(list.resp_body)["tasks"])["artifacts"] == []
  end

  test "encoded task IDs remain opaque rather than becoming REST action suffixes" do
    {server, store} = TestSupport.server()
    task = Task.new("ctx", id: "opaque/path:subscribe")
    :ok = TaskStore.put(store, {:anonymous, nil}, task)
    opts = RestPlug.init(server: server, path: "/rest")
    response = request(:get, "/rest/tasks/opaque%2Fpath%3Asubscribe", nil, opts)
    assert response.status == 200
    assert Jason.decode!(response.resp_body)["id"] == task["id"]
  end

  defp request(method, path, body, opts) do
    conn(method, path, if(body, do: Jason.encode!(body), else: nil))
    |> put_req_header("content-type", "application/a2a+json")
    |> put_req_header("a2a-version", "1.0")
    |> RestPlug.call(opts)
  end
end
