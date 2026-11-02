# ArborA2A usage rules

- Supervise TaskStore and listeners explicitly. Use Client for JSON-RPC/REST,
  generated stubs for gRPC and the optional gRPC server macro for that binding.
- Preserve principal, tenant, context and task bindings. Use stable identities
  with persistence; do not share credentials across issuers or resources.
- Return a direct message or validated task, or `{:async, function}` for managed
  work. Blocking sends wait for terminal/interrupted state; immediate mode may
  acknowledge submitted work. Emit updates with the supplied handler context.
- Managed cancellation stops owned workers. Host-owned work needs a truthful
  `handle_cancel/2` acknowledgement. Shutdown cannot undo external side effects.
- Persist explicitly when restart recovery is needed. The supplied file adapter
  has one writer and does not replay business work or provide cluster consensus.
- Handle slow-consumer/disconnect errors and reconnect by subscribing again;
  streams are live and do not promise replay. Do not cancel work merely because
  a reader disconnects.
- Acquire OAuth access tokens through direct OIDCC calls and a token provider;
  independently verify incoming access tokens and application authorization.
  ID tokens are not resource credentials. Card metadata does not establish trust.
- Treat webhook delivery as duplicate-capable. Retain the default destination
  policy unless trusted host configuration explicitly permits private services.
  Reconfigure any private policy on store restart with `push_options:`.
- Verify signed cards with host trust anchors and allowed algorithms. Configure
  extended-card authentication and implement the semantics of advertised extensions.
- Treat call timeouts as unknown outcomes; calls and business side effects are
  never automatically replayed. Keep the optional gRPC dependency mitigation.
- Consult docs/COVERAGE.md and docs/REQUIREMENTS.md for scope and evidence limits.
