defmodule Arbor.A2A.Output do
  @moduledoc false
  alias Arbor.A2A.Error

  def validate(result, card, config) do
    advertised =
      card["defaultOutputModes"] ++ Enum.flat_map(card["skills"], &Map.get(&1, "outputModes", []))

    accepted = Map.get(config, "acceptedOutputModes", [])
    parts = result_parts(result)

    valid = Enum.all?(parts, &supported?(&1, advertised, accepted))
    if valid, do: :ok, else: {:error, Error.new(:invalid_agent_response)}
  end

  def event(event, context) do
    parts =
      case event do
        %{"task" => task} -> result_parts(%{"task" => task})
        %{"artifactUpdate" => %{"artifact" => %{"parts" => parts}}} -> parts
        %{"statusUpdate" => %{"status" => %{"message" => message}}} -> message["parts"]
        _ -> []
      end

    valid = Enum.all?(parts, &supported?(&1, context.output_modes, context.accepted_output_modes))
    if valid, do: :ok, else: {:error, Error.new(:invalid_agent_response)}
  end

  defp supported?(part, advertised, accepted) do
    type = media(part)
    type in advertised and (accepted == [] or type in accepted)
  end

  defp result_parts(%{"message" => message}), do: message["parts"]

  defp result_parts(%{"task" => task}) do
    messages = Enum.filter(Map.get(task, "history", []), &(&1["role"] == "ROLE_AGENT"))

    messages =
      if task["status"]["message"], do: [task["status"]["message"] | messages], else: messages

    Enum.flat_map(messages ++ Map.get(task, "artifacts", []), & &1["parts"])
  end

  defp media(%{"mediaType" => type}) when type != "", do: type
  defp media(%{"text" => _}), do: "text/plain"
  defp media(%{"data" => _}), do: "application/json"
  defp media(_), do: "application/octet-stream"
end
