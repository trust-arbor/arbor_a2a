defmodule Arbor.A2A.ProtocolTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  alias Arbor.A2A.{Error, Protocol}

  property "ArborRPC request IDs survive encoding and A2A validation" do
    check all(id <- one_of([integer(), string(:alphanumeric)]), n <- integer()) do
      envelope = Protocol.request("GetTask", %{"id" => to_string(n)}, id)

      assert {:ok, "GetTask", %{"id" => value}, ^id} =
               Protocol.decode_request(Jason.encode!(envelope))

      assert value == to_string(n)

      assert {:ok, %{"n" => ^n}} =
               Protocol.decode_response(Jason.encode!(Protocol.response(id, %{"n" => n})), id)
    end
  end

  for {name, value} <- [
        batch: [],
        scalar: 1,
        nil: nil,
        old_version: %{"jsonrpc" => "1.0", "method" => "GetTask", "id" => 1},
        notification: %{"jsonrpc" => "2.0", "method" => "GetTask"},
        null_id: %{"jsonrpc" => "2.0", "method" => "GetTask", "id" => nil},
        bool_id: %{"jsonrpc" => "2.0", "method" => "GetTask", "id" => true},
        float_id: %{"jsonrpc" => "2.0", "method" => "GetTask", "id" => 1.1},
        numeric_method: %{"jsonrpc" => "2.0", "method" => 3, "id" => 1}
      ] do
    test "rejects invalid request #{name}" do
      assert {:error, nil, %Error{code: -32_600}} =
               Protocol.validate_request(unquote(Macro.escape(value)))
    end
  end

  test "parse errors, mixed envelopes and nonobject params have distinct errors" do
    assert {:error, nil, %Error{code: -32_700}} = Protocol.decode_request("{")

    assert {:error, nil, %Error{code: -32_600}} =
             Protocol.validate_request(%{
               "jsonrpc" => "2.0",
               "id" => 1,
               "method" => "GetTask",
               "result" => %{}
             })

    assert {:error, 1, %Error{code: -32_602}} =
             Protocol.validate_request(%{
               "jsonrpc" => "2.0",
               "id" => 1,
               "method" => "GetTask",
               "params" => []
             })

    assert {:ok, "ListTasks", %{}, 1} =
             Protocol.decode_request(~s({"jsonrpc":"2.0","method":"ListTasks","id":1}))
  end

  for field <- ~w(id jsonrpc result) do
    test "responses missing #{field} are rejected" do
      response = Map.delete(Protocol.response(12, %{}), unquote(field))
      assert {:error, :invalid_response} = Protocol.decode_response(Jason.encode!(response), 12)
    end
  end

  test "rejects wrong request ID and result/error ambiguity" do
    assert {:error, :invalid_response} =
             Protocol.decode_response(Jason.encode!(Protocol.response(2, %{})), 1)

    mixed = Map.put(Protocol.response(1, %{}), "error", %{"code" => -32_600, "message" => "bad"})
    assert {:error, :invalid_response} = Protocol.decode_response(Jason.encode!(mixed), 1)
    assert {:error, :invalid_response} = Protocol.decode_response("not JSON", 1)
  end

  for {name, code} <- [
        task_not_found: -32_001,
        task_not_cancelable: -32_002,
        push_not_supported: -32_003,
        unsupported_operation: -32_004,
        content_type_not_supported: -32_005,
        invalid_agent_response: -32_006,
        extended_card_not_configured: -32_007,
        extension_required: -32_008,
        version_not_supported: -32_009
      ] do
    test "A2A #{name} has canonical code and typed ErrorInfo" do
      error = Error.new(unquote(name))
      assert error.code == unquote(code)

      assert [%{"@type" => "type.googleapis.com/google.rpc.ErrorInfo", "reason" => reason}] =
               error.data

      assert is_binary(reason)

      assert {:error, ^error} =
               Protocol.decode_response(Jason.encode!(Protocol.error(1, error)), 1)
    end
  end
end
