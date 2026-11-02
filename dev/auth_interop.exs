Code.require_file("../test/support/agent.ex", __DIR__)
alias Arbor.A2A.{Client, HttpPlug, Message, TestSupport}
[issuer] = System.argv()

{:ok, provider} =
  Oidcc.ProviderConfiguration.Worker.start_link(%{
    issuer: issuer,
    provider_configuration_opts: %{quirks: %{allow_unsafe_http: true}}
  })

# OIDCC's worker loads configuration/JWKS asynchronously; wait on its actual client context.
wait = fn wait, remaining ->
  case Oidcc.ClientContext.from_configuration_worker(provider, "caller", "fixture-caller") do
    {:ok, context} ->
      context

    _ when remaining > 0 ->
      Process.sleep(100)
      wait.(wait, remaining - 1)

    _ ->
      raise "OIDCC configuration did not become ready"
  end
end

context = wait.(wait, 200)

{:ok, token} =
  Oidcc.client_credentials_token(provider, "caller", "fixture-caller", %{
    scope: [],
    preferred_auth_methods: [:client_secret_basic]
  })

true = is_binary(token.access.token)

{:ok, introspection} =
  Oidcc.introspect_token(token.access.token, provider, "resource", "fixture-resource", %{
    client_self_only: false,
    preferred_auth_methods: [:client_secret_basic]
  })

true = introspection.active
true = "https://agent.example.test/a2a" in List.wrap(introspection.aud)
true = introspection.iss == issuer

{server, _store} = TestSupport.server()

authenticate = fn conn ->
  case Plug.Conn.get_req_header(conn, "authorization") do
    ["Bearer " <> access] ->
      with {:ok, value} <-
             Oidcc.introspect_token(access, provider, "resource", "fixture-resource", %{
               client_self_only: false,
               preferred_auth_methods: [:client_secret_basic]
             }),
           true <-
             value.active and value.iss == issuer and value.exp > System.system_time(:second),
           true <- "https://agent.example.test/a2a" in List.wrap(value.aud),
           true <- is_binary(value.sub) do
        {:ok, {issuer, value.sub}}
      else
        _ -> {:error, :unauthorized}
      end

    _ ->
      {:error, :unauthorized}
  end
end

{:ok, http} =
  Bandit.start_link(
    plug: {HttpPlug, server: server, authenticate: authenticate},
    port: 0,
    ip: {127, 0, 0, 1}
  )

{:ok, {_, port}} = ThousandIsland.listener_info(http)
url = "http://127.0.0.1:#{port}/a2a"
{:ok, client} = Client.new(url, token_provider: fn -> {:ok, token.access.token} end)
{:ok, %{"task" => task}} = Client.send_message(client, Message.text("authorized"))
{:ok, _} = Client.get_task(client, task["id"])
{:ok, anonymous} = Client.new(url)
{:error, {:http_status, 401}} = Client.list_tasks(anonymous)
{:ok, forged} = Client.new(url, token_provider: fn -> {:ok, "not-a-token"} end)
{:error, {:http_status, 401}} = Client.list_tasks(forged)

verifier = Base.url_encode64(:crypto.strong_rand_bytes(48), padding: false)
nonce = Arbor.A2A.id()

opts = %{
  scope: ["openid"],
  preferred_auth_methods: [:client_secret_basic],
  redirect_uri: "http://127.0.0.1:4180/callback",
  state: Arbor.A2A.id(),
  nonce: nonce,
  require_pkce: true,
  pkce_verifier: verifier
}

{:ok, redirect} = Oidcc.create_redirect_url(provider, "caller", "fixture-caller", opts)
redirect = IO.iodata_to_binary(redirect)
true = "S256" in context.provider_configuration.code_challenge_methods_supported

{code, 0} =
  System.cmd(
    Path.expand("../.venv/bin/python", __DIR__),
    [Path.expand("../test/interop/keycloak_login.py", __DIR__), redirect, opts.state],
    stderr_to_stdout: false
  )

{:ok, user_token} =
  Oidcc.retrieve_token(String.trim(code), provider, "caller", "fixture-caller", opts)

true = is_binary(user_token.id.claims["sub"])

{:ok, refreshed} =
  Oidcc.refresh_token(user_token, provider, "caller", "fixture-caller", %{
    preferred_auth_methods: [:client_secret_basic]
  })

true = refreshed.id.claims["sub"] == user_token.id.claims["sub"]

{:ok, user_info} =
  Oidcc.introspect_token(refreshed.access.token, provider, "resource", "fixture-resource", %{
    client_self_only: false,
    preferred_auth_methods: [:client_secret_basic]
  })

true = is_binary(user_info.sub)

{:ok, user_client} = Client.new(url, token_provider: fn -> {:ok, refreshed.access.token} end)
{:error, %Arbor.A2A.Error{code: -32_001}} = Client.get_task(user_client, task["id"])

IO.puts(
  Jason.encode!(%{
    assertions: 12,
    peer: "Keycloak",
    oidcc: to_string(Application.spec(:oidcc, :vsn))
  })
)
