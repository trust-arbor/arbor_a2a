defmodule Arbor.A2A.Client do
  alias Arbor.A2A.{
    AgentCard,
    HTTP,
    HTTPStream,
    Protocol,
    Response,
    RestBinding,
    SSE,
    StreamValidator
  }

  @moduledoc """
  Stateless A2A 1.0 JSON-RPC HTTP client. Calls return `{:ok, map}` or
  `{:error, Arbor.A2A.Error.t() | term()}`. Requests are never automatically
  retried. A timeout can mean an unknown remote outcome.

  Optional `token_provider: fn -> {:ok, access_token} end` delegates token
  acquisition to the host (including direct OIDCC calls). Tokens are requested
  per call and are neither persisted nor sent to discovery endpoints.
  """
  alias Arbor.RPC.JSONRPC
  @derive {Inspect, except: [:token_provider, :http_auth, :headers, :tls_options]}
  defstruct [
    :url,
    :tenant,
    :token_provider,
    :http_auth,
    tls_options: [],
    binding: :jsonrpc,
    headers: [],
    timeout: 10_000,
    max_response_bytes: 1_048_576
  ]

  def new(url, opts \\ []) do
    with {:ok, _} <- HTTP.validate_url(url),
         {:ok, _} <- HTTP.tls_options(opts),
         true <- Keyword.get(opts, :binding, :jsonrpc) in [:jsonrpc, :rest],
         true <- is_nil(opts[:token_provider]) or is_function(opts[:token_provider], 0),
         true <- is_nil(opts[:http_auth]) or is_function(opts[:http_auth], 0),
         true <- is_nil(opts[:http_auth]) or is_nil(opts[:token_provider]),
         headers = Keyword.get(opts, :headers, []),
         true <-
           is_list(headers) and
             Enum.all?(headers, fn
               {k, v} when is_binary(k) and is_binary(v) ->
                 String.downcase(k) not in ~w(authorization host content-length content-type a2a-version) and
                   not String.contains?(k <> v, ["\r", "\n"])

               _ ->
                 false
             end) do
      {:ok, struct!(__MODULE__, Keyword.merge(opts, url: url))}
    else
      false -> {:error, :invalid_client_options}
      error -> error
    end
  rescue
    _ -> {:error, :invalid_client_options}
  end

  def send_message(client, message, config \\ %{}),
    do: call(client, "SendMessage", %{"message" => message, "configuration" => config})

  def get_task(client, id, opts \\ %{}), do: call(client, "GetTask", Map.put(opts, "id", id))
  def cancel_task(client, id), do: call(client, "CancelTask", %{"id" => id})
  def list_tasks(client, opts \\ %{}), do: call(client, "ListTasks", opts)

  def call(%__MODULE__{} = client, method, params) when is_binary(method) and is_map(params) do
    id = JSONRPC.generate_id()
    params = if client.tenant, do: Map.put(params, "tenant", client.tenant), else: params

    with {:ok, auth} <- authorization(client),
         {:ok, verb, url, body} <- RestBinding.request(client, method, params, id),
         {:ok, response} <-
           HTTP.request(
             verb,
             url,
             auth ++
               client.headers ++
               [
                 {"content-type", "application/json"},
                 {"accept", "application/json"},
                 {"a2a-version", "1.0"}
               ],
             body,
             timeout: client.timeout,
             max_response_bytes: client.max_response_bytes,
             tls_options: client.tls_options
           ),
         :ok <- valid_response(client.binding, response) do
      with {:ok, result} <- RestBinding.decode(client.binding, response, id),
           do: Response.validate(method, result)
    end
  end

  @doc "Reduce an SSE response synchronously; returning `{:halt, acc}` closes the owned socket."
  def stream(client, method, params, acc, callback)
      when method in ~w(SendStreamingMessage SubscribeToTask) do
    id = JSONRPC.generate_id()
    params = if client.tenant, do: Map.put(params, "tenant", client.tenant), else: params

    with {:ok, auth} <- authorization(client),
         {:ok, verb, url, body} <- RestBinding.request(client, method, params, id) do
      initial = %{
        acc: acc,
        status: nil,
        sse: SSE.new(max_event_bytes: client.max_response_bytes),
        validator: StreamValidator.new(),
        binding: client.binding,
        json: "",
        media: nil
      }

      reducer = fn event, state -> stream_event(event, state, id, callback) end

      case HTTPStream.reduce(
             url,
             auth ++
               client.headers ++
               [
                 {"content-type", "application/json"},
                 {"accept", "text/event-stream"},
                 {"a2a-version", "1.0"}
               ],
             body,
             initial,
             reducer,
             method: verb,
             tls_options: client.tls_options,
             timeout: client.timeout
           ) do
        {:ok, result} -> {:ok, result.acc}
        error -> error
      end
    end
  end

  defp stream_event({:status, status}, state, _, _), do: {:cont, %{state | status: status}}

  defp stream_event({:headers, headers}, state, _, _) do
    media =
      Enum.find_value(headers, state.media, fn {k, v} ->
        if k == "content-type", do: String.downcase(hd(String.split(v, ";")))
      end)

    {:cont, %{state | media: media}}
  end

  defp stream_event(
         {:data, data},
         %{status: 200, media: "text/event-stream"} = state,
         id,
         callback
       ) do
    with {:ok, events, sse} <- SSE.feed(state.sse, data) do
      Enum.reduce_while(
        events,
        {:cont, %{state | sse: sse}},
        &reduce_stream_event(&1, &2, id, callback)
      )
    end
  end

  defp stream_event({:data, bytes}, %{media: media} = state, _, _)
       when media in ["application/json", "application/a2a+json"] do
    if byte_size(state.json) + byte_size(bytes) <= state.sse.max_event_bytes,
      do: {:cont, %{state | json: state.json <> bytes}},
      else: {:error, :response_too_large}
  end

  defp stream_event(:done, %{json: bytes} = state, id, _) when bytes != "" do
    case RestBinding.decode(state.binding, %{body: bytes, status: state.status}, id) do
      {:error, _} = error -> error
      _ -> {:error, :invalid_stream_response}
    end
  end

  defp stream_event(:done, state, _, _) do
    if state.validator.finished and SSE.finish(state.sse) == :ok,
      do: {:cont, state},
      else: {:error, :incomplete_stream}
  end

  defp stream_event(_, state, _, _), do: {:error, {:invalid_stream_http_response, state.status}}

  defp reduce_stream_event(bytes, {:cont, state}, id, callback) do
    case parse_stream_event(bytes, state, id, callback) do
      {:cont, state} -> {:cont, {:cont, state}}
      result -> {:halt, result}
    end
  end

  defp parse_stream_event(bytes, state, id, callback) do
    with {:ok, value} <- decode_stream(state.binding, bytes, id),
         {:ok, value, validator} <- StreamValidator.accept(state.validator, value) do
      case callback.(value, state.acc) do
        {:cont, acc} -> {:cont, %{state | acc: acc, validator: validator}}
        {:halt, acc} -> {:halt, %{state | acc: acc, validator: validator}}
      end
    end
  end

  @doc "Fetch and validate a public Agent Card. Does not acquire or send credentials."
  def discover(base_url, opts \\ []) do
    with {:ok, uri} <- HTTP.validate_url(base_url),
         url = URI.to_string(%{uri | path: "/.well-known/agent-card.json", query: nil}),
         {:ok, response} <- HTTP.request("GET", url, [{"accept", "application/json"}], nil, opts),
         :ok <- valid_http_response(response),
         {:ok, card} <- Jason.decode(response.body),
         :ok <- AgentCard.validate(card),
         {:ok, interface} <-
           AgentCard.interface(
             card,
             if(opts[:binding] == :rest, do: "HTTP+JSON", else: "JSONRPC")
           ),
         {:ok, selected} <- HTTP.validate_url(interface["url"]),
         true <-
           {uri.scheme, uri.host, uri.port} == {selected.scheme, selected.host, selected.port} do
      {:ok, card}
    else
      false -> {:error, :untrusted_agent_interface}
      error -> error
    end
  end

  defp authorization(%{http_auth: nil, token_provider: nil}), do: {:ok, []}
  defp authorization(%{http_auth: nil, token_provider: provider}), do: bearer(provider)

  defp authorization(%{http_auth: provider}) do
    case provider.() do
      {:ok, scheme, credential} when is_binary(scheme) and is_binary(credential) ->
        if Regex.match?(~r/^[A-Za-z][A-Za-z0-9_-]*$/, scheme) and credential != "" and
             not String.contains?(credential, ["\r", "\n"]),
           do: {:ok, [{"authorization", scheme <> " " <> credential}]},
           else: {:error, :token_unavailable}

      _ ->
        {:error, :token_unavailable}
    end
  rescue
    _ -> {:error, :token_unavailable}
  catch
    _, _ -> {:error, :token_unavailable}
  end

  defp bearer(provider) do
    case provider.() do
      {:ok, token} when is_binary(token) and byte_size(token) > 0 ->
        if String.contains?(token, ["\r", "\n"]),
          do: {:error, :token_unavailable},
          else: {:ok, [{"authorization", "Bearer " <> token}]}

      _ ->
        {:error, :token_unavailable}
    end
  rescue
    _ -> {:error, :token_unavailable}
  catch
    _, _ -> {:error, :token_unavailable}
  end

  defp valid_response(:jsonrpc, response), do: valid_http_response(response)

  defp valid_response(:rest, response) do
    valid =
      Enum.any?(response.headers, fn {k, v} ->
        k == "content-type" and
          hd(String.split(v, ";")) in ["application/json", "application/a2a+json"]
      end)

    if valid, do: :ok, else: {:error, :invalid_content_type}
  end

  defp decode_stream(:jsonrpc, bytes, id), do: Protocol.decode_response(bytes, id)
  defp decode_stream(:rest, bytes, _), do: Jason.decode(bytes)

  defp valid_http_response(%{status: 200, headers: headers}) do
    valid =
      Enum.any?(headers, fn {k, v} ->
        k == "content-type" and String.downcase(hd(String.split(v, ";"))) == "application/json"
      end)

    if valid, do: :ok, else: {:error, :invalid_content_type}
  end

  defp valid_http_response(%{status: status}), do: {:error, {:http_status, status}}
end
