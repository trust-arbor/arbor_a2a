defmodule Arbor.A2A.StreamValidator do
  @moduledoc false
  alias Arbor.A2A.{Error, Response, Task}
  def new, do: %{started: false, finished: false, id: nil, context: nil}
  def accept(%{finished: true}, _), do: invalid()

  def accept(state, value) do
    with {:ok, event} <- Response.stream(value), do: advance(state, event)
  end

  defp advance(%{started: false} = state, %{"message" => _} = event),
    do: {:ok, event, %{state | started: true, finished: true}}

  defp advance(%{started: false} = state, %{"task" => task} = event),
    do:
      {:ok, event,
       %{
         state
         | started: true,
           id: task["id"],
           context: task["contextId"],
           finished: Task.terminal?(task)
       }}

  defp advance(%{started: true} = state, event) do
    update = event["statusUpdate"] || event["artifactUpdate"]

    if update && update["taskId"] == state.id && update["contextId"] == state.context do
      terminal = Task.terminal?(%{"status" => update["status"]})
      {:ok, event, %{state | finished: terminal}}
    else
      invalid()
    end
  end

  defp advance(_, _), do: invalid()
  defp invalid, do: {:error, Error.new(:invalid_agent_response)}
end
