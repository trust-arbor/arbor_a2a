defmodule Arbor.A2A.Request do
  @moduledoc """
  Schema-aware field aliases for implemented requests. Serializers emit
  camelCase; parsers also accept original protobuf names. Alternate spellings
  of one field in the same object are rejected because map ordering is lost.
  Arbitrary Struct/Value payloads and metadata are never recursively renamed.
  This is not a complete ProtoJSON type/field normalizer.
  """
  alias Arbor.A2A.Error

  @list ~w(context_id page_size page_token history_length status_timestamp_after include_artifacts)
  @message ~w(message_id context_id task_id reference_task_ids)
  @config ~w(accepted_output_modes task_push_notification_config history_length return_immediately)

  def normalize("SendMessage", params) do
    with {:ok, params} <- child(params, "message", &message/1) do
      child(params, "configuration", &fields(&1, @config))
    end
  end

  def normalize("GetTask", params), do: fields(params, ["history_length"])
  def normalize("ListTasks", params), do: fields(params, @list)
  def normalize(_method, params) when is_map(params), do: {:ok, params}
  def normalize(_, _), do: invalid()

  defp message(value) do
    with {:ok, value} <- fields(value, @message) do
      child(value, "parts", &parts/1)
    end
  end

  defp parts(values) when is_list(values) do
    Enum.reduce_while(values, {:ok, []}, fn value, {:ok, acc} ->
      case fields(value, ["media_type"]) do
        {:ok, part} -> {:cont, {:ok, [part | acc]}}
        error -> {:halt, error}
      end
    end)
    |> reverse_parts()
  end

  defp parts(_), do: invalid()
  defp reverse_parts({:ok, values}), do: {:ok, Enum.reverse(values)}
  defp reverse_parts(error), do: error

  defp child(map, key, fun) when is_map(map) do
    case Map.fetch(map, key) do
      :error ->
        {:ok, map}

      {:ok, value} ->
        with {:ok, normalized} <- fun.(value), do: {:ok, Map.put(map, key, normalized)}
    end
  end

  defp child(_, _, _), do: invalid()

  defp fields(map, names) when is_map(map) do
    Enum.reduce_while(names, {:ok, map}, fn proto, {:ok, current} ->
      json = camel(proto)

      case {Map.fetch(current, proto), Map.has_key?(current, json)} do
        {:error, _} ->
          {:cont, {:ok, current}}

        {{:ok, _}, true} ->
          {:halt, invalid()}

        {{:ok, value}, false} ->
          {:cont, {:ok, current |> Map.delete(proto) |> Map.put(json, value)}}
      end
    end)
  end

  defp fields(_, _), do: invalid()

  defp camel(proto) do
    [first | rest] = String.split(proto, "_")
    first <> Enum.map_join(rest, &String.capitalize/1)
  end

  defp invalid, do: {:error, Error.new(:invalid_params)}
end
