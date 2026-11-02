defmodule Arbor.A2A.HTTPStream do
  @moduledoc false
  alias Arbor.A2A.HTTP

  def reduce(url, headers, body, acc, callback, opts) do
    timeout = Keyword.get(opts, :timeout, 30_000)

    with {:ok, uri} <- HTTP.validate_url(url),
         {:ok, tls_options} <- HTTP.tls_options(opts),
         {:ok, conn} <-
           Mint.HTTP1.connect(String.to_existing_atom(uri.scheme), uri.host, uri.port,
             mode: :passive,
             transport_opts:
               [timeout: timeout] ++
                 if(uri.scheme == "https", do: tls_options, else: [])
           ) do
      try do
        path = (uri.path || "/") <> if(uri.query, do: "?" <> uri.query, else: "")

        case Mint.HTTP1.request(conn, Keyword.get(opts, :method, "POST"), path, headers, body) do
          {:ok, conn, ref} ->
            receive_chunks(
              conn,
              ref,
              callback,
              acc,
              System.monotonic_time(:millisecond) + timeout
            )

          _ ->
            {:error, :http_transport_error}
        end
      after
        Mint.HTTP1.close(conn)
      end
    end
  rescue
    _ -> {:error, :http_transport_error}
  end

  defp receive_chunks(conn, ref, callback, acc, deadline) do
    timeout = deadline - System.monotonic_time(:millisecond)

    if timeout <= 0 do
      {:error, :timeout}
    else
      case Mint.HTTP1.recv(conn, 0, timeout) do
        {:ok, conn, events} ->
          continue(consume(events, ref, callback, acc), conn, ref, callback, deadline)

        _ ->
          {:error, :http_transport_error}
      end
    end
  end

  defp continue({:cont, acc}, conn, ref, callback, deadline),
    do: receive_chunks(conn, ref, callback, acc, deadline)

  defp continue({:halt, acc}, _, _, _, _), do: {:ok, acc}
  defp continue(error, _, _, _, _), do: error

  defp consume([], _, _, acc), do: {:cont, acc}

  defp consume([event | rest], ref, callback, acc) do
    value =
      case event do
        {:status, ^ref, value} -> {:status, value}
        {:headers, ^ref, value} -> {:headers, value}
        {:data, ^ref, value} -> {:data, value}
        {:done, ^ref} -> :done
      end

    case callback.(value, acc) do
      {:cont, acc} when value != :done -> consume(rest, ref, callback, acc)
      {:cont, acc} -> {:halt, acc}
      result -> result
    end
  end
end
