# ArborA2A usage rules

- Use `Arbor.A2A.Client` for supported JSON-RPC calls and mount `HttpPlug` in a
  host-owned listener. Supervise a TaskStore explicitly; no durable job engine
  is created implicitly.
- Preserve principal, tenant, context and task bindings. Share public issuer
  metadata where appropriate, not credentials or authorization across resources.
- Return a terminal/interrupted task for blocking SendMessage, or explicitly
  request nonblocking mode. Return direct replies with the supplied context ID.
- Implement `handle_cancel/2` only when host work can actually be stopped.
  Callback shutdown cannot undo external side effects.
- Acquire OAuth access tokens through the host token provider, which may call
  OIDCC directly. Verify incoming access tokens independently; never use an
  ID token as a resource access token.
- Apply outbound URL trust policy before accepting externally supplied URLs.
  Client discovery refuses cross-origin interface selection and sends no token.
- Handle timeouts as unknown remote outcomes. The library does not replay calls.
- Consult docs/COVERAGE.md before assuming streaming, push, signed cards,
  complete OAuth/OIDC or additional bindings are implemented.
