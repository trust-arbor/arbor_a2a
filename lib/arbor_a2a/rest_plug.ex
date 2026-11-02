defmodule Arbor.A2A.RestPlug do
  @moduledoc """
  HTTP+JSON binding for the same server and authorization model as `HttpPlug`.
  Mount with `server: server, path: "/a2a/rest", authenticate: callback`.
  Routes follow the canonical proto, including tenant-prefixed paths. Error
  bodies use google.rpc.Status JSON with typed A2A ErrorInfo details.
  """
  @behaviour Plug
  import Plug.Conn
  alias Arbor.A2A.{Error, HttpPlug, Server}
  @impl true
  def init(opts), do: HttpPlug.init(opts) |> Keyword.put_new(:rest, true)
  @impl true
  def call(%{request_path: "/.well-known/agent-card.json"} = conn, opts),
    do: HttpPlug.call(conn, opts)

  def call(conn, opts) do
    conn = put_resp_header(conn, "cache-control", "no-store")

    with {:ok, principal} <- authenticate(conn, opts),
         :ok <- HttpPlug.version(conn),
         {:ok, conn} <- HttpPlug.extensions(conn, opts[:server]),
         {:ok, method, params} <- route(conn, opts),
         {:ok, conn, params} <- body(conn, params, opts) do
      dispatch(conn, opts, method, params, principal)
    else
      {:error, :unauthorized} ->
        conn |> put_resp_header("www-authenticate", "Bearer") |> send_resp(401, "Unauthorized")

      {:error, :forbidden} ->
        send_resp(conn, 403, "Forbidden")

      {:error, :not_found} ->
        send_resp(conn, 404, "Not found")

      {:error, {:http, status, error}} ->
        error_reply(conn, status, "INVALID_ARGUMENT", error)

      {:error, error} ->
        reply(conn, {:error, error})

      :error ->
        reply(conn, {:error, Error.new(:version_not_supported)})
    end
  end

  defp dispatch(conn, opts, method, params, principal)
       when method in ~w(SendStreamingMessage SubscribeToTask) do
    case Server.stream(opts[:server], method, params, principal,
           extensions: conn.assigns[:a2a_extensions] || []
         ) do
      {:ok, events} -> HttpPlug.stream_reply(conn, events, & &1)
      error -> reply(conn, error)
    end
  end

  defp dispatch(conn, opts, method, params, principal),
    do:
      reply(
        conn,
        Server.dispatch(opts[:server], method, params, principal,
          extensions: conn.assigns[:a2a_extensions] || []
        )
      )

  defp authenticate(conn, opts), do: HttpPlug.authenticate(conn, opts[:authenticate])

  defp route(conn, opts) do
    path = opts[:path]

    if conn.request_path == path or String.starts_with?(conn.request_path, path <> "/") do
      segments =
        conn.request_path
        |> String.replace_prefix(path, "")
        |> String.split("/", trim: true)

      {segments, tenant} = tenant_prefix(opts[:server].tenant, segments)

      params =
        conn |> fetch_query_params() |> Map.fetch!(:query_params) |> Map.delete("A2A-Version")

      params =
        Map.new(params, fn
          {"includeArtifacts", "true"} -> {"includeArtifacts", true}
          {"includeArtifacts", "false"} -> {"includeArtifacts", false}
          pair -> pair
        end)

      case endpoint(conn.method, segments) do
        {method, keys} ->
          {:ok, method, Map.merge(params, Map.merge(tenant, decode_path_keys(keys)))}

        _ ->
          {:error, :not_found}
      end
    else
      {:error, :not_found}
    end
  end

  defp tenant_prefix(tenant, [first | rest] = segments) when is_binary(tenant) do
    if URI.decode(first) == tenant, do: {rest, %{"tenant" => tenant}}, else: {segments, %{}}
  end

  defp tenant_prefix(_, segments), do: {segments, %{}}
  defp decode_path_keys(keys), do: Map.new(keys, fn {key, value} -> {key, URI.decode(value)} end)

  defp endpoint("POST", ["message:send"]), do: {"SendMessage", %{}}
  defp endpoint("POST", ["message:stream"]), do: {"SendStreamingMessage", %{}}
  defp endpoint("GET", ["tasks"]), do: {"ListTasks", %{}}
  defp endpoint("GET", ["extendedAgentCard"]), do: {"GetExtendedAgentCard", %{}}

  defp endpoint("GET", ["tasks", id]) do
    if String.ends_with?(id, ":subscribe"),
      do: {"SubscribeToTask", %{"id" => String.replace_suffix(id, ":subscribe", "")}},
      else: {"GetTask", %{"id" => id}}
  end

  defp endpoint("POST", ["tasks", id]) do
    if String.ends_with?(id, ":subscribe"),
      do: {"SubscribeToTask", %{"id" => String.replace_suffix(id, ":subscribe", "")}},
      else: cancel_endpoint(id)
  end

  defp endpoint("POST", ["tasks", id, "pushNotificationConfigs"]),
    do: {"CreateTaskPushNotificationConfig", %{"taskId" => id}}

  defp endpoint("GET", ["tasks", id, "pushNotificationConfigs"]),
    do: {"ListTaskPushNotificationConfigs", %{"taskId" => id}}

  defp endpoint(verb, ["tasks", id, "pushNotificationConfigs", config])
       when verb in ~w(GET DELETE),
       do:
         {if(verb == "GET",
            do: "GetTaskPushNotificationConfig",
            else: "DeleteTaskPushNotificationConfig"
          ), %{"taskId" => id, "id" => config}}

  defp endpoint(_, _), do: nil

  defp cancel_endpoint(id) do
    if String.ends_with?(id, ":cancel"),
      do: {"CancelTask", %{"id" => String.replace_suffix(id, ":cancel", "")}},
      else: nil
  end

  defp body(%{method: "POST"} = conn, params, opts) do
    media =
      get_req_header(conn, "content-type")
      |> Enum.map(&String.downcase(hd(String.split(&1, ";"))))

    if media in [["application/a2a+json"], ["application/json"]] do
      read_json_body(conn, params, opts[:max_body_bytes])
    else
      {:error, {:http, 415, Error.new(:content_type_not_supported)}}
    end
  end

  defp body(conn, params, _), do: {:ok, conn, params}

  defp read_json_body(conn, params, limit) do
    with {:ok, bytes, conn} when byte_size(bytes) <= limit <-
           read_body(conn, length: limit, read_timeout: 5000),
         {:ok, value} when is_map(value) <- decode_body(bytes),
         true <- matching_bindings?(params, value) do
      {:ok, conn, Map.merge(value, params)}
    else
      _ -> {:error, Error.new(:invalid_params)}
    end
  end

  defp decode_body(""), do: {:ok, %{}}
  defp decode_body(bytes), do: Jason.decode(bytes)

  defp matching_bindings?(params, value),
    do: Enum.all?(params, fn {k, v} -> not Map.has_key?(value, k) or value[k] == v end)

  defp reply(conn, {:ok, result}), do: json(conn, 200, result)

  defp reply(conn, {:error, %Error{} = error}) do
    {status, name} = http_error(error)

    error_reply(conn, status, name, error)
  end

  defp error_reply(conn, status, name, error) do
    json(conn, status, %{
      "error" => %{
        "code" => status,
        "status" => name,
        "message" => error.message,
        "details" => error.data || []
      }
    })
  end

  @doc false
  def http_error(%{code: -32_001}), do: {404, "NOT_FOUND"}
  def http_error(%{code: code}) when code in [-32_006, -32_603], do: {500, "INTERNAL"}
  def http_error(%{code: -32_601}), do: {501, "UNIMPLEMENTED"}

  def http_error(%{code: code}) when code in [-32_700, -32_600, -32_602, -32_005],
    do: {400, "INVALID_ARGUMENT"}

  def http_error(_), do: {400, "FAILED_PRECONDITION"}

  defp json(conn, status, value) do
    media =
      if Enum.any?(get_req_header(conn, "accept"), &String.contains?(&1, "application/a2a+json")),
        do: "application/a2a+json",
        else: "application/json"

    conn |> put_resp_content_type(media) |> send_resp(status, Jason.encode!(value))
  end
end
