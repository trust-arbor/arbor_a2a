defmodule Arbor.A2A.Response do
  @moduledoc "Method-specific response validation for untrusted peers."
  alias Arbor.A2A.{AgentCard, Error, Message, Schema, Task}

  def validate(method, result) do
    with module when not is_nil(module) <- Schema.response_type(method),
         {:ok, normalized} <- Schema.normalize(module, result),
         true <- semantics?(method, normalized) do
      {:ok, normalized}
    else
      _ -> {:error, Error.new(:invalid_agent_response)}
    end
  end

  def stream(event) do
    with {:ok, event} <- Schema.normalize(Arbor.A2A.Proto.Lf.A2a.V1.StreamResponse, event),
         true <- map_size(event) == 1,
         true <- stream_value?(event),
         do: {:ok, event},
         else: (_ -> {:error, Error.new(:invalid_agent_response)})
  end

  defp semantics?("SendMessage", %{"task" => task} = value),
    do: map_size(value) == 1 and Task.validate(task) == :ok

  defp semantics?("SendMessage", %{"message" => message} = value),
    do: map_size(value) == 1 and agent_message?(message)

  defp semantics?("SendMessage", _), do: false

  defp semantics?(method, task) when method in ~w(GetTask CancelTask),
    do: Task.validate(task) == :ok

  defp semantics?("ListTasks", value),
    do:
      Enum.all?(value["tasks"], &(Task.validate(&1) == :ok)) and value["pageSize"] in 1..100 and
        value["totalSize"] >= length(value["tasks"])

  defp semantics?("GetExtendedAgentCard", card), do: AgentCard.validate(card) == :ok
  defp semantics?(_, _), do: true
  defp stream_value?(%{"task" => task}), do: Task.validate(task) == :ok
  defp stream_value?(%{"message" => message}), do: agent_message?(message)
  defp stream_value?(%{"statusUpdate" => event}), do: event["status"]["state"] in Task.states()

  defp stream_value?(%{"artifactUpdate" => event}),
    do: Enum.all?(event["artifact"]["parts"], &Message.valid_part?/1)

  defp stream_value?(_), do: false

  defp agent_message?(message),
    do:
      Message.validate(message) == :ok and message["role"] == "ROLE_AGENT" and
        Message.nonempty?(message["contextId"])
end
