defmodule Arbor.A2A.RestBinding do
  @moduledoc false
  alias Arbor.A2A.{Error, Protocol}

  @routes %{
    "SendMessage" => {"POST", "/message:send"},
    "SendStreamingMessage" => {"POST", "/message:stream"},
    "GetTask" => {"GET", "/tasks/{id}"},
    "ListTasks" => {"GET", "/tasks"},
    "CancelTask" => {"POST", "/tasks/{id}:cancel"},
    "SubscribeToTask" => {"GET", "/tasks/{id}:subscribe"},
    "CreateTaskPushNotificationConfig" => {"POST", "/tasks/{taskId}/pushNotificationConfigs"},
    "GetTaskPushNotificationConfig" => {"GET", "/tasks/{taskId}/pushNotificationConfigs/{id}"},
    "ListTaskPushNotificationConfigs" => {"GET", "/tasks/{taskId}/pushNotificationConfigs"},
    "DeleteTaskPushNotificationConfig" =>
      {"DELETE", "/tasks/{taskId}/pushNotificationConfigs/{id}"},
    "GetExtendedAgentCard" => {"GET", "/extendedAgentCard"}
  }
  def request(client, method, params, id) do
    if client.binding == :jsonrpc do
      {:ok, "POST", client.url, Jason.encode!(Protocol.request(method, params, id))}
    else
      rest_request(client.url, method, params)
    end
  end

  defp rest_request(url, method, params) do
    case @routes[method] do
      nil ->
        {:error, Error.new(:method_not_found)}

      {verb, route} ->
        keys = Regex.scan(~r/\{(\w+)\}/, route) |> Enum.map(&List.last/1)

        path =
          Enum.reduce(keys, route, fn key, path ->
            String.replace(
              path,
              "{" <> key <> "}",
              URI.encode(params[key] || "", &URI.char_unreserved?/1)
            )
          end)

        tenant =
          if params["tenant"] in [nil, ""],
            do: "",
            else: "/" <> URI.encode(params["tenant"], &URI.char_unreserved?/1)

        params = Map.drop(params, ["tenant" | keys])
        uri = URI.parse(url)
        query = if verb == "GET" and map_size(params) > 0, do: URI.encode_query(params), else: nil

        url =
          URI.to_string(%{
            uri
            | path: String.trim_trailing(uri.path || "", "/") <> tenant <> path,
              query: query
          })

        {:ok, verb, url, if(verb == "POST", do: Jason.encode!(params), else: nil)}
    end
  end

  def decode(:jsonrpc, response, id), do: Protocol.decode_response(response.body, id)

  def decode(:rest, response, _) do
    case Jason.decode(response.body) do
      {:ok, %{"error" => error}} ->
        {:error, Error.from_reason(error_reason(error))}

      {:ok, result} when response.status == 200 and is_map(result) ->
        {:ok, result}

      _ ->
        {:error, :invalid_http_response}
    end
  end

  defp error_reason(error) do
    Enum.find_value(Map.get(error, "details", []), fn value ->
      if value["@type"] == "type.googleapis.com/google.rpc.ErrorInfo", do: value["reason"]
    end)
  end
end
