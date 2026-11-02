defmodule Arbor.A2A.TypesTest do
  use ExUnit.Case, async: true
  alias Arbor.A2A.{AgentCard, Error, Message, Task}
  import Arbor.A2A.TestSupport

  test "message IDs, ProtoJSON roles and task/context bindings" do
    message = Message.text("hello", task_id: "task", context_id: "context")
    assert :ok = Message.validate(message)
    assert message["role"] == "ROLE_USER"
    assert message["messageId"] != Message.text("hello")["messageId"]
    assert :ok = Message.validate(Message.text("reply", role: "ROLE_AGENT"))
  end

  for value <- [
        nil,
        [],
        %{},
        %{"parts" => []},
        %{"messageId" => "", "role" => "ROLE_USER", "parts" => [%{"text" => "x"}]},
        %{"messageId" => "id", "role" => "user", "parts" => [%{"text" => "x"}]}
      ] do
    test "rejects malformed message #{inspect(value)}" do
      assert {:error, %Error{code: -32_602}} = Message.validate(unquote(Macro.escape(value)))
    end
  end

  for {field, value} <- [
        {"text", ""},
        {"raw", "AA=="},
        {"url", "https://example.com/file"},
        {"data", nil},
        {"data", [1, 2]},
        {"data", %{"x" => true}}
      ] do
    test "accepts ProtoJSON #{field} part #{inspect(value)}" do
      assert Message.valid_part?(%{unquote(field) => unquote(Macro.escape(value))})
    end
  end

  for value <- [
        %{},
        nil,
        [],
        %{"text" => 1},
        %{"raw" => "not base64"},
        %{"url" => ""},
        %{"text" => "a", "data" => nil},
        %{"text" => "a", "metadata" => []},
        %{"text" => "a", "mediaType" => 7}
      ] do
    test "rejects malformed or ambiguous part #{inspect(value)}" do
      refute Message.valid_part?(unquote(Macro.escape(value)))
    end
  end

  for field <-
        ~w(name description version supportedInterfaces capabilities defaultInputModes defaultOutputModes skills) do
    test "Agent Card requires #{field}" do
      assert {:error, :invalid_agent_card} =
               AgentCard.validate(Map.delete(card(), unquote(field)))
    end
  end

  test "selects supported JSONRPC version and rejects unknown binding" do
    assert :ok = AgentCard.validate(card())
    assert {:ok, %{"protocolBinding" => "JSONRPC"}} = AgentCard.jsonrpc_interface(card())
    value = put_in(card(), ["supportedInterfaces", Access.at(0), "protocolBinding"], "GRPC")
    assert {:error, :unsupported_interface} = AgentCard.jsonrpc_interface(value)
  end

  for state <- Task.states() do
    test "valid state #{state} has correct terminal classification" do
      task = Task.new("ctx", state: unquote(state))
      assert :ok = Task.validate(task)

      assert Task.terminal?(task) ==
               unquote(state) in ~w(TASK_STATE_COMPLETED TASK_STATE_FAILED TASK_STATE_CANCELED TASK_STATE_REJECTED)
    end
  end

  test "task validation rejects invalid status, history and artifacts" do
    task = Task.new("ctx")

    for invalid <- [
          put_in(task, ["status", "state"], "completed"),
          Map.put(task, "history", [nil]),
          Map.put(task, "artifacts", [%{"artifactId" => "a", "parts" => []}]),
          put_in(task, ["status", "timestamp"], "tomorrow")
        ] do
      assert {:error, %Error{code: -32_006}} = Task.validate(invalid)
    end
  end

  test "history projection returns most recent entries and omits zero-length history" do
    task = Map.put(Task.new("ctx"), "history", Enum.map(1..4, &Message.text(to_string(&1))))
    assert length(Task.project(task, 2)["history"]) == 2
    refute Map.has_key?(Task.project(task, 0), "history")
    assert Task.project(task, nil) == task
  end
end
