defmodule Arbor.A2A.HttpPlug do
  @moduledoc """
  Host-mounted A2A JSON-RPC endpoint and public `/.well-known/agent-card.json`.
  Supply `server: server`, optional `path: "/a2a"`, and an `authenticate`
  function returning `{:ok, principal}` or `{:error, :unauthorized | :forbidden}`.
  Authentication runs before reading request bodies. Hosts verify access tokens
  and apply application authorization; ID tokens are not API credentials.
  """
  @behaviour Plug
  import Plug.Conn
  alias Arbor.A2A.{Error, Extensions, Protocol, Server}
  @impl true
  def init(opts) do
    server = Keyword.fetch!(opts, :server)

    if Map.get(server.card, "securityRequirements", []) != [] and
         not is_function(opts[:authenticate], 1),
       do: raise(ArgumentError, "declared security requires an authenticate callback")

    opts |> Keyword.put_new(:path, "/a2a") |> Keyword.put_new(:max_body_bytes, 1_048_576)
  end

  @impl true
  def call(%{method: "GET", request_path: "/.well-known/agent-card.json"} = conn, opts) do
    server = opts[:server]
    bytes = Jason.encode!(server.card)
    etag = "\"" <> Base.encode16(:crypto.hash(:sha256, bytes), case: :lower) <> "\""

    modified =
      Calendar.strftime(server.card_updated_at || DateTime.utc_now(), "%a, %d %b %Y %H:%M:%S GMT")

    conn =
      conn
      |> put_resp_header("cache-control", "public, max-age=60")
      |> put_resp_header("etag", etag)
      |> put_resp_header("last-modified", modified)

    matches =
      get_req_header(conn, "if-none-match")
      |> Enum.flat_map(&String.split(&1, ","))
      |> Enum.map(&String.trim/1)

    if etag in matches or "*" in matches,
      do: send_resp(conn, 304, ""),
      else: json(conn, 200, server.card)
  end

  def call(conn, opts) do
    cond do
      conn.request_path not in [opts[:path], opts[:path] <> "/"] ->
        send_resp(conn, 404, "Not found")

      conn.method != "POST" ->
        conn |> put_resp_header("allow", "POST") |> send_resp(405, "Method not allowed")

      true ->
        authenticated(conn, opts)
    end
  end

  defp authenticated(conn, opts) do
    conn = put_resp_header(conn, "cache-control", "no-store")

    case authenticate(conn, opts[:authenticate]) do
      {:ok, principal} -> process(conn, opts, principal)
      {:error, :forbidden} -> send_resp(conn, 403, "Forbidden")
      _ -> conn |> put_resp_header("www-authenticate", "Bearer") |> send_resp(401, "Unauthorized")
    end
  end

  def authenticate(_, nil), do: {:ok, :anonymous}

  def authenticate(conn, fun) when is_function(fun, 1) do
    case fun.(conn) do
      {:ok, principal} when not is_nil(principal) -> {:ok, principal}
      {:error, :forbidden} -> {:error, :forbidden}
      _ -> {:error, :unauthorized}
    end
  rescue
    _ -> {:error, :unauthorized}
  catch
    _, _ -> {:error, :unauthorized}
  end

  defp process(conn, opts, principal) do
    case get_req_header(conn, "content-type") do
      [type] ->
        if String.downcase(hd(String.split(type, ";"))) == "application/json",
          do: body(conn, opts, principal),
          else: send_resp(conn, 415, "Unsupported media type")

      _ ->
        send_resp(conn, 415, "Unsupported media type")
    end
  end

  defp body(conn, opts, principal) do
    limit = opts[:max_body_bytes]

    case read_body(conn,
           length: opts[:max_body_bytes],
           read_length: min(opts[:max_body_bytes], 64_000),
           read_timeout: 5_000
         ) do
      {:ok, bytes, conn} when byte_size(bytes) <= limit ->
        dispatch(conn, bytes, opts, principal)

      {:more, _, conn} ->
        send_resp(conn, 413, "Payload too large")

      {:ok, _, conn} ->
        send_resp(conn, 413, "Payload too large")

      {:error, _} ->
        send_resp(conn, 400, "Invalid request body")
    end
  end

  defp dispatch(conn, bytes, opts, principal) do
    case Protocol.decode_request(bytes) do
      {:ok, method, params, id} ->
        dispatch_version(conn, opts, method, params, principal, id)

      {:error, id, error} ->
        json(conn, 200, Protocol.error(id, error))
    end
  end

  defp dispatch_version(conn, opts, method, params, principal, id) do
    with :ok <- version(conn), {:ok, conn} <- extensions(conn, opts[:server]) do
      dispatch_method(conn, opts, method, params, principal, id)
    else
      :error -> rpc_reply(conn, id, {:error, Error.new(:version_not_supported)})
      {:error, error} -> rpc_reply(conn, id, {:error, error})
    end
  end

  defp dispatch_method(conn, opts, method, params, principal, id)
       when method in ~w(SendStreamingMessage SubscribeToTask) do
    case Server.stream(opts[:server], method, params, principal,
           extensions: conn.assigns[:a2a_extensions] || []
         ) do
      {:ok, events} -> stream_reply(conn, events, &Protocol.response(id, &1), id)
      error -> rpc_reply(conn, id, error)
    end
  end

  defp dispatch_method(conn, opts, method, params, principal, id),
    do:
      rpc_reply(
        conn,
        id,
        Server.dispatch(opts[:server], method, params, principal,
          extensions: conn.assigns[:a2a_extensions] || []
        )
      )

  @doc false
  def stream_reply(conn, events, encode, id \\ nil) do
    conn =
      conn
      |> put_resp_content_type("text/event-stream")
      |> put_resp_header("cache-control", "no-store")
      |> send_chunked(200)

    Enum.reduce_while(events, conn, &send_stream_event(&1, &2, encode, id))
  end

  defp send_stream_event(event, conn, encode, id) do
    bytes = stream_bytes(event, encode, id)

    case chunk(conn, bytes) do
      {:ok, conn} -> if match?({:error, _}, event), do: {:halt, conn}, else: {:cont, conn}
      {:error, _} -> {:halt, conn}
    end
  end

  defp stream_bytes(:heartbeat, _, _), do: ": keepalive\n\n"

  defp stream_bytes({:error, %Error{} = error}, _, id),
    do: "data: " <> Jason.encode!(Protocol.error(id, error)) <> "\n\n"

  defp stream_bytes({:error, _}, encode, id),
    do: stream_bytes({:error, Error.new(:internal_error)}, encode, id)

  defp stream_bytes(value, encode, _), do: "data: " <> Jason.encode!(encode.(value)) <> "\n\n"

  @doc false
  def extensions(conn, server) do
    requested =
      get_req_header(conn, "a2a-extensions")
      |> Enum.flat_map(&String.split(&1, ","))
      |> Enum.map(&String.trim/1)

    with {:ok, active} <- Extensions.negotiate(server.card, requested) do
      conn = assign(conn, :a2a_extensions, active)

      {:ok,
       if(active == [],
         do: conn,
         else: put_resp_header(conn, "a2a-extensions", Enum.join(active, ","))
       )}
    end
  end

  defp rpc_reply(conn, id, {:ok, result}), do: json(conn, 200, Protocol.response(id, result))

  defp rpc_reply(conn, id, {:error, %Error{} = error}),
    do: json(conn, 200, Protocol.error(id, error))

  def version(conn) do
    values = get_req_header(conn, "a2a-version")

    value =
      if values == [],
        do: Map.get(Plug.Conn.fetch_query_params(conn).query_params, "A2A-Version", "0.3"),
        else: if(length(values) == 1, do: hd(values), else: "invalid")

    if is_binary(value) and Regex.match?(~r/^1\.0(?:\.\d+)?$/, value), do: :ok, else: :error
  end

  defp json(conn, status, value),
    do:
      conn |> put_resp_content_type("application/json") |> send_resp(status, Jason.encode!(value))
end
