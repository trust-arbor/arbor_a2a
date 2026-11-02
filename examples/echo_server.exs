defmodule Arbor.A2A.Examples.Echo do
  @moduledoc false
  @behaviour Arbor.A2A.Server.Handler
  alias Arbor.A2A.{Message, Task}
  @impl true
  def handle_message(%{"message" => message}, context) do
    reply =
      Message.text("Echo: " <> hd(message["parts"])["text"],
        role: "ROLE_AGENT",
        context_id: context.context_id,
        task_id: context.task_id
      )

    task =
      Task.new(context.context_id,
        id: context.task_id,
        state: "TASK_STATE_COMPLETED",
        history: [message, reply]
      )

    {:ok, %{"task" => task}}
  end
end

port =
  case System.argv() do
    [value] -> String.to_integer(value)
    [] -> 4180
  end

url = "http://127.0.0.1:#{port}/a2a"

card =
  Arbor.A2A.AgentCard.new("Echo", url,
    skills: [
      %{"id" => "echo", "name" => "Echo", "description" => "Repeat text", "tags" => ["echo"]}
    ]
  )

{:ok, server} =
  Arbor.A2A.Server.new(
    handler: Arbor.A2A.Examples.Echo,
    store: Arbor.A2A.Examples.Store,
    card: card
  )

{:ok, _supervisor} =
  Supervisor.start_link(
    [
      {Arbor.A2A.TaskStore, name: Arbor.A2A.Examples.Store},
      {Bandit, plug: {Arbor.A2A.HttpPlug, server: server}, ip: {127, 0, 0, 1}, port: port}
    ],
    strategy: :one_for_one
  )

IO.puts("Echo agent at #{url}")
Process.sleep(:infinity)
