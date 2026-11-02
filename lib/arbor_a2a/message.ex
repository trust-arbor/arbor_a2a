defmodule Arbor.A2A.Message do
  @moduledoc "Construct and validate ProtoJSON A2A messages and parts."
  alias Arbor.A2A.{Error, Schema}
  alias Arbor.A2A.Proto.Lf.A2a.V1, as: Wire
  @roles ~w(ROLE_USER ROLE_AGENT)
  def text(text, opts \\ []) when is_binary(text) do
    %{
      "messageId" => Keyword.get_lazy(opts, :id, &Arbor.A2A.id/0),
      "role" => Keyword.get(opts, :role, "ROLE_USER"),
      "parts" => [%{"text" => text}]
    }
    |> put_optional("contextId", opts[:context_id])
    |> put_optional("taskId", opts[:task_id])
  end

  def validate(%{"messageId" => id, "role" => role, "parts" => [_ | _] = parts} = message) do
    if Schema.valid?(Wire.Message, message) and nonempty?(id) and role in @roles and
         Enum.all?(parts, &valid_part?/1) and
         Enum.all?(~w(taskId contextId), fn k ->
           not Map.has_key?(message, k) or nonempty?(message[k])
         end) and
         (not Map.has_key?(message, "metadata") or is_map(message["metadata"])) do
      :ok
    else
      {:error, Error.new(:invalid_params)}
    end
  end

  def validate(_), do: {:error, Error.new(:invalid_params)}

  def valid_part?(part) when is_map(part) do
    fields = Enum.filter(~w(text raw url data), &Map.has_key?(part, &1))

    valid_content?(fields, part) and
      (not Map.has_key?(part, "metadata") or is_map(part["metadata"])) and
      Enum.all?(~w(filename mediaType), fn k ->
        not Map.has_key?(part, k) or is_binary(part[k])
      end)
  end

  def valid_part?(_), do: false
  defp valid_content?(["text"], part), do: is_binary(part["text"])

  defp valid_content?(["raw"], part),
    do: is_binary(part["raw"]) and match?({:ok, _}, Base.decode64(part["raw"]))

  defp valid_content?(["url"], part), do: nonempty?(part["url"])
  defp valid_content?(["data"], _), do: true
  defp valid_content?(_, _), do: false
  def nonempty?(value), do: is_binary(value) and byte_size(value) > 0
  defp put_optional(map, _key, nil), do: map
  defp put_optional(map, key, value), do: Map.put(map, key, value)
end
