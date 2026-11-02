defmodule Arbor.A2A.RequestAliasTest do
  use ExUnit.Case, async: true
  alias Arbor.A2A.{Error, Request, Server}
  import Arbor.A2A.TestSupport

  @tag :request_alias
  test "GetTask accepts the original protobuf history_length field" do
    {server, _} = server()
    {:ok, %{"task" => task}} = Server.dispatch(server, "SendMessage", params())

    assert {:ok, result} =
             Server.dispatch(server, "GetTask", %{"id" => task["id"], "history_length" => 0})

    refute Map.has_key?(result, "history")
  end

  @tag :request_alias
  test "SendMessage accepts aliases in the message and configuration" do
    {server, _} = server()

    input = %{
      "message" => %{
        "message_id" => "input",
        "role" => "ROLE_USER",
        "parts" => [%{"text" => "hello"}]
      },
      "configuration" => %{"history_length" => 0}
    }

    assert {:ok, %{"task" => result}} = Server.dispatch(server, "SendMessage", input)
    refute Map.has_key?(result, "history")
  end

  test "alias collisions are refused and cannot mutate task storage" do
    {server, _} = server()
    {:ok, %{"task" => task}} = Server.dispatch(server, "SendMessage", params())

    assert {:error, %Error{code: -32_602}} =
             Server.dispatch(server, "GetTask", %{
               "id" => task["id"],
               "historyLength" => 0,
               "history_length" => 1
             })

    assert {:ok, full} = Server.dispatch(server, "GetTask", %{"id" => task["id"]})
    assert length(full["history"]) == 2
  end

  test "normalization preserves Struct/Value keys and only renames schema fields" do
    data = %{
      "context_id" => "data",
      "media_type" => "payload",
      "_meta" => %{"task_id" => "owned"}
    }

    metadata = %{"message_id" => "caller", "messageId" => "also caller"}

    input = %{
      "message" => %{
        "message_id" => "m",
        "metadata" => metadata,
        "parts" => [%{"data" => data, "media_type" => "application/json", "metadata" => metadata}]
      },
      "metadata" => metadata
    }

    assert {:ok, result} = Request.normalize("SendMessage", input)
    assert result["metadata"] == metadata
    assert result["message"]["metadata"] == metadata
    assert result["message"]["messageId"] == "m"
    assert hd(result["message"]["parts"])["data"] == data
    assert hd(result["message"]["parts"])["metadata"] == metadata
    assert hd(result["message"]["parts"])["mediaType"] == "application/json"
  end

  test "ListTasks normalizes cursor filters without touching opaque tokens" do
    assert {:ok,
            %{
              "contextId" => "ctx",
              "pageSize" => 1,
              "pageToken" => "opaque",
              "includeArtifacts" => true
            }} =
             Request.normalize("ListTasks", %{
               "context_id" => "ctx",
               "page_size" => 1,
               "page_token" => "opaque",
               "include_artifacts" => true
             })
  end

  test "nested alias collisions and malformed child objects are errors" do
    for input <- [
          %{"message" => %{"message_id" => "a", "messageId" => "b"}},
          %{"configuration" => %{"return_immediately" => true, "returnImmediately" => false}},
          %{"message" => %{"parts" => [%{"media_type" => "x", "mediaType" => "y"}]}},
          %{"configuration" => []}
        ] do
      assert {:error, %Error{code: -32_602}} = Request.normalize("SendMessage", input)
    end
  end
end
