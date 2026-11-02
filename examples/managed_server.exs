defmodule Arbor.A2A.Examples.Managed do
  @moduledoc false
  @behaviour Arbor.A2A.Server.Handler
  alias Arbor.A2A.{Message, Server, Task}
  @impl true
  def handle_message(%{"message" => message}, _context) do
    {:async,
     fn context ->
       :ok =
         Server.emit(context, %{
           "statusUpdate" => %{
             "taskId" => context.task_id,
             "contextId" => context.context_id,
             "status" => %{"state" => "TASK_STATE_WORKING"}
           }
         })

       reply =
         Message.text("Managed echo: " <> hd(message["parts"])["text"],
           role: "ROLE_AGENT",
           context_id: context.context_id,
           task_id: context.task_id
         )

       {:ok,
        %{
          "task" =>
            Task.new(context.context_id,
              id: context.task_id,
              state: "TASK_STATE_COMPLETED",
              history: [message, reply]
            )
        }}
     end}
  end
end

port =
  case System.argv() do
    [value] -> String.to_integer(value)
    [] -> 4181
  end

card =
  Arbor.A2A.AgentCard.new("Managed echo", "http://127.0.0.1:#{port}/a2a",
    skills: [
      %{"id" => "echo", "name" => "Echo", "description" => "Supervised echo", "tags" => ["echo"]}
    ]
  )

card = put_in(card, ["capabilities", "streaming"], true)
{:ok, store} = Arbor.A2A.TaskStore.start_link()

{:ok, server} =
  Arbor.A2A.Server.new(handler: Arbor.A2A.Examples.Managed, store: store, card: card)

{:ok, _listener} =
  Bandit.start_link(plug: {Arbor.A2A.HttpPlug, server: server}, ip: {127, 0, 0, 1}, port: port)

IO.puts("Managed echo at http://127.0.0.1:#{port}/a2a")
Process.sleep(:infinity)
