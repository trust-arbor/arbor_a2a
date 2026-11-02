defmodule Arbor.A2A.Client do
  @moduledoc """
  Stateless A2A 1.0 JSON-RPC HTTP client. Calls return `{:ok, map}` or
  `{:error, Arbor.A2A.Error.t() | term()}`. Requests are never automatically
  retried. A timeout can mean an unknown remote outcome.

  Optional `token_provider: fn -> {:ok, access_token} end` delegates token
  acquisition to the host (including direct OIDCC calls). Tokens are requested
  per call and are neither persisted nor sent to discovery endpoints.
  """
  alias Arbor.A2A.{AgentCard, HTTP, Protocol}
  alias Arbor.RPC.JSONRPC
  @derive {Inspect, except: [:token_provider, :headers]}
  defstruct [
    :url,
    :tenant,
    :token_provider,
    headers: [],
    timeout: 10_000,
    max_response_bytes: 1_048_576
  ]

  def new(url, opts \\ []) do
    with {:ok, _} <- HTTP.validate_url(url),
         true <- is_nil(opts[:token_provider]) or is_function(opts[:token_provider], 0),
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

    with {:ok, auth} <- authorization(client.token_provider),
         {:ok, body} <- Jason.encode(Protocol.request(method, params, id)),
         {:ok, response} <-
           HTTP.request(
             "POST",
             client.url,
             auth ++
               client.headers ++
               [
                 {"content-type", "application/json"},
                 {"accept", "application/json"},
                 {"a2a-version", "1.0"}
               ],
             body,
             timeout: client.timeout,
             max_response_bytes: client.max_response_bytes
           ),
         :ok <- valid_http_response(response) do
      Protocol.decode_response(response.body, id)
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
         {:ok, interface} <- AgentCard.jsonrpc_interface(card),
         {:ok, selected} <- HTTP.validate_url(interface["url"]),
         true <-
           {uri.scheme, uri.host, uri.port} == {selected.scheme, selected.host, selected.port} do
      {:ok, card}
    else
      false -> {:error, :untrusted_agent_interface}
      error -> error
    end
  end

  defp authorization(nil), do: {:ok, []}

  defp authorization(provider) do
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

  defp valid_http_response(%{status: 200, headers: headers}) do
    valid =
      Enum.any?(headers, fn {k, v} ->
        k == "content-type" and String.downcase(hd(String.split(v, ";"))) == "application/json"
      end)

    if valid, do: :ok, else: {:error, :invalid_content_type}
  end

  defp valid_http_response(%{status: status}), do: {:error, {:http_status, status}}
end
