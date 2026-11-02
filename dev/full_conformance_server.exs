Code.require_file("../test/support/agent.ex", __DIR__)
Code.require_file("conformance_agent.exs", __DIR__)

defmodule Arbor.A2A.ConformanceGRPC do
  use Arbor.A2A.GRPCServer, server: Agent.get(Arbor.A2A.ConformanceState, & &1)
end

{:ok, _grpc_supervisor} =
  GRPC.Server.Supervisor.start_link(
    servers: [Arbor.A2A.ConformanceGRPC],
    port: 0,
    start_server: true,
    adapter_opts: [ip: {127, 0, 0, 1}]
  )

grpc_port = :ranch.get_port(inspect(Arbor.A2A.ConformanceGRPC))
[port] = System.argv()
port = String.to_integer(port)
{:ok, store} = Arbor.A2A.TaskStore.start_link()

card =
  Arbor.A2A.TestSupport.card("http://127.0.0.1:#{port}/a2a")
  |> put_in(["capabilities", "streaming"], true)
  |> Map.put("defaultOutputModes", ["text/plain", "application/json", "application/octet-stream"])
  |> Map.put("defaultInputModes", ["text/plain", "application/json", "application/octet-stream"])

card =
  Map.update!(
    card,
    "supportedInterfaces",
    &(&1 ++
        [
          %{
            "url" => "http://127.0.0.1:#{port}/rest",
            "protocolBinding" => "HTTP+JSON",
            "protocolVersion" => "1.0"
          },
          %{
            "url" => "http://127.0.0.1:#{grpc_port}",
            "protocolBinding" => "GRPC",
            "protocolVersion" => "1.0"
          }
        ])
  )

{:ok, server} =
  Arbor.A2A.Server.new(handler: Arbor.A2A.ConformanceAgent, store: store, card: card)

{:ok, _} = Agent.start_link(fn -> server end, name: Arbor.A2A.ConformanceState)
rest = Arbor.A2A.RestPlug.init(server: server, path: "/rest")
rpc = Arbor.A2A.HttpPlug.init(server: server)

plug = fn conn, _ ->
  if String.starts_with?(conn.request_path, "/rest"),
    do: Arbor.A2A.RestPlug.call(conn, rest),
    else: Arbor.A2A.HttpPlug.call(conn, rpc)
end

{:ok, _} =
  Bandit.start_link(plug: plug, ip: {127, 0, 0, 1}, port: port)

IO.puts("A2A_READY #{port}")
Process.sleep(:infinity)
