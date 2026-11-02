# Changelog

## Unreleased

- Initial A2A 1.0 JSON-RPC client/server foundation using ArborRPC envelopes.
- Agent Cards, direct/task messages, task/history/list/cancel, identity-isolated
  bounded storage, HTTP auth hooks, version/errors and a bounded SSE codec.
- Contract/property tests, selected official TCK and bidirectional official SDK
  interop, pinned specification sources, evidence receipts and CI scaffolding.
- Protocol coverage, authentication boundaries, examples and remaining work
  documented. No release or full-protocol certification is claimed.
- Completed the standard-operation implementation surface: live streaming and
  subscriptions, managed work/cancellation/recovery, durable state/outbox, push
  notification configuration/delivery, extended/signed cards and extensions.
- Added canonical generated protobuf validation/types, REST client/Plug and an
  optional gRPC server; preserved ProtoJSON Value null in the binary binding.
- Qualified additional original TCK assertions, real REST/gRPC/SSE SDK peers,
  direct OIDCC exchanges against Keycloak, mutual TLS and cold package consumers.
- Added a normative prose inventory, managed streaming example, expanded CI and
  explicit upstream-conformance/dependency-security qualifications.
