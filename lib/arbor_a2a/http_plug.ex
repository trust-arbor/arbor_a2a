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
  alias Arbor.A2A.{Error, Protocol, Server}
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
    conn
    |> put_resp_header("cache-control", "public, max-age=60")
    |> json(200, opts[:server].card)
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
    case authenticate(conn, opts[:authenticate]) do
      {:ok, principal} -> process(conn, opts, principal)
      {:error, :forbidden} -> send_resp(conn, 403, "Forbidden")
      _ -> conn |> put_resp_header("www-authenticate", "Bearer") |> send_resp(401, "Unauthorized")
    end
  end

  defp authenticate(_, nil), do: {:ok, :anonymous}

  defp authenticate(conn, fun) when is_function(fun, 1) do
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
        case version(conn) do
          :ok ->
            rpc_reply(conn, id, Server.dispatch(opts[:server], method, params, principal))

          :error ->
            json(conn, 200, Protocol.error(id, Error.new(:version_not_supported)))
        end

      {:error, id, error} ->
        json(conn, 200, Protocol.error(id, error))
    end
  end

  defp rpc_reply(conn, id, {:ok, result}), do: json(conn, 200, Protocol.response(id, result))

  defp rpc_reply(conn, id, {:error, %Error{} = error}),
    do: json(conn, 200, Protocol.error(id, error))

  defp version(conn) do
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
