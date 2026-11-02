defmodule Arbor.A2A.Protocol do
  @moduledoc "Strict A2A JSON-RPC validation around ArborRPC envelope mechanics."
  alias Arbor.A2A.Error
  alias Arbor.RPC.JSONRPC
  def request(method, params, id), do: JSONRPC.request(method, params, id)
  def response(id, result), do: JSONRPC.response(id, result)
  def error(id, %Error{} = error), do: JSONRPC.error(id, Error.to_map(error))

  def decode_request(bytes) when is_binary(bytes) do
    case Jason.decode(bytes) do
      {:ok, value} -> validate_request(value)
      {:error, _} -> {:error, nil, Error.new(:parse_error)}
    end
  end

  def validate_request(%{"jsonrpc" => "2.0", "method" => method, "id" => id} = envelope)
      when is_binary(method) and (is_binary(id) or is_integer(id)) do
    cond do
      Map.has_key?(envelope, "result") or Map.has_key?(envelope, "error") ->
        {:error, nil, Error.new(:invalid_request)}

      not is_map(Map.get(envelope, "params", %{})) ->
        {:error, id, Error.new(:invalid_params)}

      true ->
        {:ok, method, Map.get(envelope, "params", %{}), id}
    end
  end

  def validate_request(_), do: {:error, nil, Error.new(:invalid_request)}

  def decode_response(bytes, id) do
    case Jason.decode(bytes) do
      {:ok, %{"jsonrpc" => "2.0", "id" => ^id} = envelope} ->
        case {Map.fetch(envelope, "result"), Map.fetch(envelope, "error")} do
          {{:ok, result}, :error} when is_map(result) ->
            {:ok, result}

          {:error, {:ok, %{"code" => code, "message" => message} = error}}
          when is_integer(code) and is_binary(message) ->
            {:error, %Error{code: code, message: message, data: error["data"]}}

          _ ->
            {:error, :invalid_response}
        end

      _ ->
        {:error, :invalid_response}
    end
  end
end
