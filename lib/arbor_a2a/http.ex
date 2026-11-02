defmodule Arbor.A2A.HTTP do
  @moduledoc """
  Finite HTTP/1 requests through Mint with TLS verification, no redirects and
  incremental response byte limits. Each operation owns and closes its socket.
  URLs are explicit host configuration; this is not a public-network SSRF filter.
  """
  def validate_url(url) when is_binary(url) do
    case URI.new(url) do
      {:ok, %URI{scheme: scheme, host: host, userinfo: nil, fragment: nil} = uri}
      when is_binary(host) ->
        if scheme == "https" or (scheme == "http" and host in ["127.0.0.1", "localhost", "::1"]),
          do: {:ok, uri},
          else: {:error, :https_required}

      _ ->
        {:error, :invalid_url}
    end
  end

  def validate_url(_), do: {:error, :invalid_url}

  def request(method, url, headers, body, opts \\ []) do
    timeout = Keyword.get(opts, :timeout, 10_000)
    limit = Keyword.get(opts, :max_response_bytes, 1_048_576)
    deadline = System.monotonic_time(:millisecond) + timeout

    with true <- valid_limits?(timeout, limit),
         {:ok, uri} <- validate_url(url),
         {:ok, conn} <-
           Mint.HTTP1.connect(String.to_existing_atom(uri.scheme), uri.host, uri.port,
             mode: :passive,
             transport_opts:
               [timeout: timeout] ++
                 if(uri.scheme == "https", do: [cacertfile: CAStore.file_path()], else: [])
           ) do
      try do
        case Mint.HTTP1.request(conn, method, request_path(uri), headers, body) do
          {:ok, conn, ref} ->
            receive_response(conn, ref, deadline, limit, %{
              status: nil,
              headers: [],
              chunks: [],
              bytes: 0
            })

          {:error, _conn, reason} ->
            {:error, {:http_transport, reason}}
        end
      after
        Mint.HTTP1.close(conn)
      end
    else
      false -> {:error, :invalid_http_options}
      {:error, %Mint.TransportError{reason: :timeout}} -> {:error, :timeout}
      {:error, reason} -> {:error, reason}
    end
  rescue
    _ -> {:error, :http_transport_error}
  end

  defp valid_limits?(timeout, limit),
    do: is_integer(timeout) and timeout > 0 and is_integer(limit) and limit > 0

  defp request_path(uri),
    do:
      if(uri.path in [nil, ""], do: "/", else: uri.path) <>
        if(uri.query, do: "?" <> uri.query, else: "")

  defp receive_response(conn, ref, deadline, limit, state) do
    remaining = deadline - System.monotonic_time(:millisecond)

    if remaining <= 0 do
      {:error, :timeout}
    else
      case Mint.HTTP1.recv(conn, 0, remaining) do
        {:ok, conn, events} ->
          continue_response(consume(events, ref, state, limit), conn, ref, deadline, limit)

        {:error, _, :timeout, _} ->
          {:error, :timeout}

        {:error, _, %Mint.TransportError{reason: :timeout}, _} ->
          {:error, :timeout}

        {:error, _, _, _} ->
          {:error, :http_transport_error}
      end
    end
  end

  defp continue_response({:done, state}, _, _, _, _),
    do:
      {:ok,
       %{
         status: state.status,
         headers: state.headers,
         body: state.chunks |> Enum.reverse() |> IO.iodata_to_binary()
       }}

  defp continue_response({:more, state}, conn, ref, deadline, limit),
    do: receive_response(conn, ref, deadline, limit, state)

  defp continue_response(error, _, _, _, _), do: error

  defp consume([], _, state, _), do: {:more, state}

  defp consume([event | rest], ref, state, limit) do
    case event do
      {:status, ^ref, status} ->
        consume(rest, ref, %{state | status: status}, limit)

      {:headers, ^ref, headers} ->
        consume(rest, ref, %{state | headers: state.headers ++ headers}, limit)

      {:data, ^ref, data} when state.bytes + byte_size(data) <= limit ->
        consume(
          rest,
          ref,
          %{state | chunks: [data | state.chunks], bytes: state.bytes + byte_size(data)},
          limit
        )

      {:data, ^ref, _} ->
        {:error, :response_too_large}

      {:done, ^ref} ->
        {:done, state}

      _ ->
        {:error, :invalid_http_response}
    end
  end
end
