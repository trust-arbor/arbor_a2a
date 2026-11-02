defmodule Arbor.A2A.Task do
  @moduledoc "A2A task construction, state checks and history projection."
  alias Arbor.A2A.{Error, Message, Schema, Timestamp}

  @states ~w(TASK_STATE_SUBMITTED TASK_STATE_WORKING TASK_STATE_COMPLETED TASK_STATE_FAILED TASK_STATE_CANCELED TASK_STATE_INPUT_REQUIRED TASK_STATE_REJECTED TASK_STATE_AUTH_REQUIRED)
  @terminal ~w(TASK_STATE_COMPLETED TASK_STATE_FAILED TASK_STATE_CANCELED TASK_STATE_REJECTED)
  def states, do: @states
  def terminal?(%{"status" => %{"state" => state}}), do: state in @terminal
  def terminal?(_), do: false

  def new(context_id, opts \\ []) do
    %{
      "id" => Keyword.get_lazy(opts, :id, &Arbor.A2A.id/0),
      "contextId" => context_id,
      "status" => %{
        "state" => Keyword.get(opts, :state, "TASK_STATE_SUBMITTED"),
        "timestamp" => DateTime.utc_now() |> DateTime.to_iso8601()
      },
      "history" => Keyword.get(opts, :history, [])
    }
  end

  def validate(%{"id" => id, "status" => %{"state" => state} = status} = task) do
    valid =
      Schema.valid?(Arbor.A2A.Proto.Lf.A2a.V1.Task, task) and Message.nonempty?(id) and
        state in @states and
        valid_context?(task) and valid_status?(status) and
        valid_items?(task, "history", &(Message.validate(&1) == :ok)) and
        valid_items?(task, "artifacts", &valid_artifact?/1)

    if valid, do: :ok, else: {:error, Error.new(:invalid_agent_response)}
  end

  def validate(_), do: {:error, Error.new(:invalid_agent_response)}

  defp valid_context?(task),
    do: not Map.has_key?(task, "contextId") or Message.nonempty?(task["contextId"])

  defp valid_status?(status),
    do:
      valid_timestamp?(status["timestamp"]) and
        (not Map.has_key?(status, "message") or Message.validate(status["message"]) == :ok)

  def project(task, nil), do: task
  def project(task, 0), do: Map.delete(task, "history")

  def project(task, length) when is_integer(length) and length > 0,
    do: Map.update(task, "history", [], &Enum.take(&1, -length))

  defp valid_items?(map, key, fun) do
    case Map.fetch(map, key) do
      :error -> true
      {:ok, values} when is_list(values) -> Enum.all?(values, fun)
      _ -> false
    end
  end

  defp valid_artifact?(%{"artifactId" => id, "parts" => [_ | _] = parts}),
    do: Message.nonempty?(id) and Enum.all?(parts, &Message.valid_part?/1)

  defp valid_artifact?(_), do: false
  defp valid_timestamp?(nil), do: true

  defp valid_timestamp?(value) when is_binary(value),
    do: match?({:ok, _}, Timestamp.parse(value))

  defp valid_timestamp?(_), do: false
end
