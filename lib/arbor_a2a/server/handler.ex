defmodule Arbor.A2A.Server.Handler do
  @moduledoc """
  Stateless, concurrent agent callback. Return `{:ok, %{"message" => message}}`
  or `{:ok, %{"task" => task}}`, or `{:error, Arbor.A2A.Error.t()}`.

  Context contains trusted `:principal`, `:tenant`, `:partition`, `:store`,
  `:context_id`, `:task_id` and `:task` (nil for a new task). Use the supplied
  identities for task results. Side effects and cancellation of host work remain
  host responsibilities. A callback timeout has an unknown business outcome.
  """
  @callback handle_message(map(), map()) ::
              {:ok, map()}
              | {:error, Arbor.A2A.Error.t()}
              | {:async, (map() -> {:ok, map()} | {:error, Arbor.A2A.Error.t()})}
  @doc "Stop the task's host work before acknowledging cancellation. Without this callback tasks are not cancelable."
  @callback handle_cancel(map(), map()) :: :ok | {:error, Arbor.A2A.Error.t()}
  @optional_callbacks handle_cancel: 2
end
