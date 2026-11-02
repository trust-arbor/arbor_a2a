defmodule Arbor.A2A.GRPCTest do
  use ExUnit.Case, async: false
  alias Arbor.A2A.{Message, TestSupport}
  alias Arbor.A2A.Proto.Lf.A2a.V1, as: Wire

  defmodule Host do
    use Arbor.A2A.GRPCServer, server: Agent.get(Arbor.A2A.GRPCTest.State, & &1)
  end

  test "real HTTP/2 protobuf client/server preserve task and typed errors" do
    {server, _} = TestSupport.server()

    start_supervised!(%{
      id: __MODULE__.State,
      start: {Agent, :start_link, [fn -> server end, [name: __MODULE__.State]]}
    })

    start_supervised!(
      {GRPC.Server.Supervisor,
       servers: [Host], port: 0, start_server: true, adapter_opts: [ip: {127, 0, 0, 1}]}
    )

    ref = inspect(Host)
    port = :ranch.get_port(ref)
    {:ok, channel} = GRPC.Stub.connect("127.0.0.1:#{port}", adapter: GRPC.Client.Adapters.Mint)
    on_exit(fn -> GRPC.Stub.disconnect(channel) end)

    request =
      Protobuf.JSON.decode!(
        Jason.encode!(%{"message" => Message.text("hello")}),
        Wire.SendMessageRequest
      )

    assert {:ok, %Wire.SendMessageResponse{payload: {:task, task}}} =
             Wire.A2AService.Stub.send_message(channel, request,
               metadata: %{"a2a-version" => "1.0"}
             )

    assert {:ok, %Wire.Task{id: id}} =
             Wire.A2AService.Stub.get_task(channel, %Wire.GetTaskRequest{id: task.id},
               metadata: %{"a2a-version" => "1.0"}
             )

    assert id == task.id

    assert {:error, %GRPC.RPCError{status: 5}} =
             Wire.A2AService.Stub.get_task(channel, %Wire.GetTaskRequest{id: "missing"},
               metadata: %{"a2a-version" => "1.0"}
             )
  end
end
