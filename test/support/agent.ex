defmodule Arbor.A2A.TestAgent do
  @moduledoc false
  @behaviour Arbor.A2A.Server.Handler
  alias Arbor.A2A.{Message, Task}
  @impl true
  def handle_cancel(_task, _context), do: :ok
  @impl true
  def handle_message(params, context) do
    message = params["message"]
    text = Enum.find_value(message["parts"], "", & &1["text"])

    case text do
      "crash" ->
        raise "private callback information"

      "invalid" ->
        {:ok, %{"task" => %{}}}

      "timeout" ->
        Process.sleep(60_000)

      "direct" ->
        {:ok,
         %{
           "message" =>
             Message.text("direct reply", role: "ROLE_AGENT", context_id: context.context_id)
         }}

      _ ->
        state = state(params, text, message)

        history = if context.task, do: Map.get(context.task, "history", []), else: []

        reply =
          Message.text("Echo: " <> text,
            role: "ROLE_AGENT",
            context_id: context.context_id,
            task_id: context.task_id
          )

        task =
          Task.new(context.context_id,
            id: context.task_id,
            state: state,
            history: history ++ [message, reply]
          )

        {:ok, %{"task" => task}}
    end
  end

  defp state(params, text, message) do
    cond do
      get_in(params, ["configuration", "returnImmediately"]) == true ->
        "TASK_STATE_WORKING"

      text == "input" or String.contains?(message["messageId"], "tck-input-required") ->
        "TASK_STATE_INPUT_REQUIRED"

      true ->
        "TASK_STATE_COMPLETED"
    end
  end
end

defmodule Arbor.A2A.TestSupport do
  @moduledoc false
  alias Arbor.A2A.{AgentCard, Message, Server, TaskStore, TestAgent}

  def card(url \\ "http://127.0.0.1:9999/a2a") do
    AgentCard.new("Echo", url,
      skills: [
        %{"id" => "echo", "name" => "Echo", "description" => "Echo messages", "tags" => ["echo"]}
      ]
    )
  end

  def server(opts \\ []) do
    {:ok, store} = TaskStore.start_link(Keyword.get(opts, :store_opts, []))

    {:ok, server} =
      Server.new(
        handler: TestAgent,
        store: store,
        card: Keyword.get(opts, :card, card()),
        timeout: Keyword.get(opts, :timeout, 1000),
        tenant: opts[:tenant]
      )

    {server, store}
  end

  def params(text \\ "hello"), do: %{"message" => Message.text(text)}
end
