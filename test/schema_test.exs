defmodule Arbor.A2A.SchemaTest do
  use ExUnit.Case, async: true
  alias Arbor.A2A.{Message, ProtoJSON, Request, Response, Schema, Task}
  alias Arbor.A2A.Proto.Lf.A2a.V1, as: Wire

  test "normalizes enum numbers, quoted integers, null/unset and base64url" do
    msg =
      Message.text("x")
      |> Map.put("role", 1)
      |> Map.put("contextId", nil)
      |> Map.put("parts", [%{"raw" => "_-8"}])

    assert {:ok, value} =
             Request.normalize("SendMessage", %{
               "message" => msg,
               "configuration" => %{"history_length" => "0"}
             })

    assert value["message"]["role"] == "ROLE_USER"
    assert value["message"]["parts"] == [%{"raw" => "/+8="}]
    refute Map.has_key?(value["message"], "contextId")
    assert value["configuration"]["historyLength"] == 0
  end

  test "Value null remains an explicitly selected Part and metadata keys remain opaque" do
    message = %{Message.text("x") | "parts" => [%{"data" => nil}]}

    assert {:ok, %{"message" => normalized}} =
             Request.normalize("SendMessage", %{"message" => message})

    assert normalized["parts"] == [%{"data" => nil}]
  end

  test "ignores unknown fields and rejects missing required fields, wrong nested types and ambiguous oneofs" do
    message = Message.text("x")

    assert {:ok, ^message} = Schema.normalize(Wire.Message, Map.put(message, "unknown", true))

    for value <- [
          Map.delete(message, "messageId"),
          Map.put(message, "extensions", 1),
          Map.put(message, "parts", [%{"text" => "x", "data" => %{}}])
        ] do
      assert {:error, _} = Schema.normalize(Wire.Message, value)
    end
  end

  test "client rejects a valid envelope with a malformed method result" do
    assert {:error, _} = Response.validate("GetTask", %{"id" => "x"})

    assert {:error, _} =
             Response.validate("SendMessage", %{
               "task" => Task.new("ctx"),
               "message" => Message.text("x")
             })

    assert {:error, _} =
             Response.validate("ListTasks", %{"tasks" => [], "pageSize" => 1, "totalSize" => 0})
  end

  test "binary binding preserves an explicitly selected Value null" do
    value =
      ProtoJSON.decode!(
        %{
          "messageId" => "m",
          "contextId" => "c",
          "role" => "ROLE_AGENT",
          "parts" => [%{"data" => nil}]
        },
        Wire.Message
      )

    assert {:data, %Google.Protobuf.Value{kind: {:null_value, :NULL_VALUE}}} =
             hd(value.parts).content

    decoded = value |> Wire.Message.encode() |> Wire.Message.decode()
    assert {:ok, json} = Protobuf.JSON.encode(decoded)
    assert hd(Jason.decode!(json)["parts"]) == %{"data" => nil}
  end
end
