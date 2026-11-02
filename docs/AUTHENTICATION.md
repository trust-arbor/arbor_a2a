# Authentication and authorization

A2A keeps credentials outside its message payloads. Agent Cards describe security
requirements; they do not establish trust in an issuer or provision credentials.
Each security requirement is an alternative, with conjunctive schemes inside it.
`Arbor.A2A.Security.select/2` selects one satisfiable requirement using explicitly
available scheme names. Required scopes are returned with the selected schemes.

Keep provider configuration and credentials bound to trusted issuer, principal,
tenant and resource configuration. Never send credentials merely because an
untrusted card advertised a metadata URL. ID tokens establish an OIDC login;
they are not API access tokens.

## Direct OIDCC integration

Use OIDCC directly. Its provider worker handles discovery/JWKS refresh; its token
APIs own OAuth/OIDC exchanges. There is no new `arbor_oauth` facade. Add `:oidcc`
to the consuming host if needed; it is optional for ArborA2A consumers.

```elixir
{:ok, provider} = Oidcc.ProviderConfiguration.Worker.start_link(%{
  issuer: "https://idp.example"
})

get_token = fn ->
  with {:ok, token} <- Oidcc.client_credentials_token(
         provider, client_id, client_secret,
         %{scope: ["agent.read"], preferred_auth_methods: [:client_secret_basic]}) do
    {:ok, token.access.token}
  end
end

{:ok, client} = Arbor.A2A.Client.new(agent_url, token_provider: get_token)
```

Wait for the worker's actual configuration/client context before making calls;
its initialization is asynchronous. Select authentication methods supported by
both the provider and the registered client. A provider advertising a method
does not mean every client registration supports it. A host may cache and refresh
its token; the library invokes the provider per request and does not persist it.

For interactive login use `Oidcc.create_redirect_url/4` with a random state,
nonce, PKCE verifier, `require_pkce: true` and an exact registered redirect URI.
The host validates callback state and binds it to the browser session, then uses
`Oidcc.retrieve_token/5`. Use `Oidcc.refresh_token/5` with the validated token
context to preserve subject binding. Provider-specific consent, device login,
SAML and service-account policy remain OIDCC/host integration choices.

`dev/auth_interop.exs` and `scripts/qualify_auth.py` demonstrate these actual
exchanges with digest-pinned Keycloak, including enforced S256 and refresh.
Only this owned loopback fixture enables OIDCC's unsafe-HTTP development quirk.
Its special cookie handling is confined to loopback test login and never enters
the library. Production provider metadata requires HTTPS.

## Incoming access tokens

The Plug authenticates before reading the body. Supply a callback returning
`{:ok, stable_principal}` or `{:error, :unauthorized | :forbidden}`. Exceptions and
unexpected callback results fail closed. Server task/config operations partition
records by this principal and tenant. The gRPC callback uses the same return
contract with request metadata as input.

A host can use `Oidcc.introspect_token/5` with its resource-server registration.
Check active state, trusted issuer, expected resource audience, time validity,
required scopes and a stable subject before returning a principal. Use
`client_self_only: false` only deliberately when introspecting another client's
access token, retaining those resource/issuer checks. The provider must issue
the required audience and subject claims. Our real-provider fixture verifies
missing/forged tokens are rejected and different subjects cannot retrieve one
another's tasks. Introspection is separate from ID-token validation.

Authorization beyond the supplied principal/tenant boundary is application
policy. Configure listener HTTPS, proxy trust, revocation handling, consent,
credential storage and security telemetry in the host.

## Other declared schemes

Custom API-key headers can be configured with `headers:`; an explicit query or
cookie credential is host configuration, never taken from discovery. HTTP
schemes can use a per-call provider:

```elixir
http_auth = fn -> {:ok, "Basic", Base.encode64(username <> ":" <> password)} end
{:ok, client} = Arbor.A2A.Client.new(agent_url, http_auth: http_auth)
```

`http_auth` and `token_provider` are mutually exclusive. Scheme/credential header
injection is rejected. Inspection redacts credentials, callbacks and TLS keys.
For mutual TLS configure `tls_options: [certfile: client_cert, keyfile: client_key]`;
custom `cacerts`/`cacertfile` trust roots are supported. Peer/hostname verification
cannot be disabled. A real TLS test requires a client certificate and rejects an
untrusted server CA or missing client certificate.

An `AUTH_REQUIRED` task status does not authorize an API request or permit
credential forwarding. The host owns any in-task authentication interaction and
must retain the same principal/resource boundaries when work resumes.
