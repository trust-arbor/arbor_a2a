Code.require_file("../test/support/agent.ex", __DIR__)

port =
  case System.argv() do
    [value] -> String.to_integer(value)
    _ -> 4180
  end

{:ok, store} = Arbor.A2A.TaskStore.start_link()
card = Arbor.A2A.TestSupport.card("http://127.0.0.1:#{port}/a2a")
{:ok, server} = Arbor.A2A.Server.new(handler: Arbor.A2A.TestAgent, store: store, card: card)

{:ok, _} =
  Bandit.start_link(plug: {Arbor.A2A.HttpPlug, server: server}, ip: {127, 0, 0, 1}, port: port)

IO.puts("A2A_READY #{port}")
Process.sleep(:infinity)
