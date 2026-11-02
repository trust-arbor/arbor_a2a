# OAuth/OIDC and host authentication

Use OIDCC directly for generic OIDC client operations. MCP protected-resource
discovery/CIMD and A2A Agent Card security selection are protocol-specific; they
do not belong in ArborRPC. A shared `arbor_oauth` package should be extracted
only if two integrations repeat meaningful policy or lifecycle code.

The package declares OIDCC as optional. A consuming host that uses its API
should also declare OIDCC explicitly. This initial implementation supplies a
token-provider and incoming-authentication boundary, not an automatic OAuth
flow or a complete Agent Card security-scheme negotiator.

For example, a host with an already configured OIDCC provider can supply:

```elixir
provider = fn ->
  case Oidcc.client_credentials_token(MyProvider, client_id, client_secret,
         %{scope: ["a2a.read"], preferred_auth_methods: [:client_secret_basic]}) do
    {:ok, %Oidcc.Token{access: %Oidcc.Token.Access{token: token, type: type}}}
        when type in ["Bearer", "bearer"] -> {:ok, token}
    _ -> {:error, :token_unavailable}
  end
end

Arbor.A2A.Client.new("https://agent.example/a2a", token_provider: provider)
```

The host owns provider supervision, discovery trust, approved auth methods,
resource-specific acquisition, token expiry/refresh, deadlines and persistence.
OIDCC's HTTP adapter can enforce a host's outbound policy, but must be supplied
for each applicable operation. Do not infer endpoint trust from a public Agent
Card or reuse a token solely because two endpoints share an issuer.

For an incoming server, configure the Plug's `authenticate` function to return
`{:ok, principal}` after access-token verification and application access checks,
or `{:error, :unauthorized | :forbidden}`. A declared card security requirement
without an authentication callback is rejected at configuration time. An absent
callback means a public anonymous service. Principal and tenant identify the
task partition; hosts retain task/skill/data authorization policy.

OIDC ID tokens establish a login identity for a client; they are not API access
tokens. A server verifier must enforce the access-token issuer, audience,
expiry, applicable scopes and token profile. Introspection or a proven JWT
access-token verifier can satisfy that boundary. Provider errors fail closed
without returning their private reason; credentials are omitted from Client
inspection. Test fixtures use fake bearer values only.

Real IdP/AS qualification, automatic authorization-code/PKCE, refresh lifecycle,
all advertised security-scheme combinations and mTLS/DPoP remain open work.
The optional dependency and example above are not evidence that those profiles
have been implemented or qualified in ArborA2A.
