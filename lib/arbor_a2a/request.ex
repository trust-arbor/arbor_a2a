defmodule Arbor.A2A.Request do
  @moduledoc "ProtoJSON request normalization against the canonical A2A schema."
  alias Arbor.A2A.{Error, Schema}

  def normalize(method, params) when is_map(params) do
    case Schema.request_type(method) do
      nil ->
        {:ok, params}

      module ->
        case Schema.normalize(module, params) do
          {:ok, normalized} -> {:ok, defaults(method, normalized)}
          _ -> {:error, Error.new(:invalid_params)}
        end
    end
  end

  def normalize(_, _), do: {:error, Error.new(:invalid_params)}

  defp defaults("ListTasks", params) do
    params |> drop_default("status", "TASK_STATE_UNSPECIFIED") |> drop_default("contextId", "")
  end

  defp defaults(method, %{"message" => message} = params)
       when method in ~w(SendMessage SendStreamingMessage) do
    Map.put(
      params,
      "message",
      message |> drop_default("taskId", "") |> drop_default("contextId", "")
    )
  end

  defp defaults(_, params), do: params

  defp drop_default(params, key, default),
    do: if(params[key] == default, do: Map.delete(params, key), else: params)
end
