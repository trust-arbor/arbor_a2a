# Requirements and host duties

Target: canonical A2A v1.0.1, protocol 1.0. `COVERAGE.md` is the human feature and
evidence tracker. The generated `test/conformance/requirements.json` inventories
normative prose blocks by stable content ID, source line and section. Inventory
entries reference implementation scopes; they are **not** individual compliance
certificates. `scripts/check_requirements.py` detects missing/changed blocks.

| Requirement family | Implementation / evidence |
| --- | --- |
| §3 operations and §4 data model | Shared `Server`, generated proto, `Schema`, `Response`; ExUnit contracts and selected original TCK cases. All eleven standard operations have implementation paths; optional capabilities require configuration. |
| Blocking/nonblocking execution, continuation and cancellation | Managed execution, per-task leases, partitioned state, bounded workers; execution, server, store and streaming regressions. Host-owned side effects need host cancellation. |
| Task streams and subscriptions | Shared task state and bounded coordinator, SSE clients/Plugs, gRPC stream adapter; live HTTP regressions and official SDK interop. No replay guarantee. |
| Push configuration and notifications | Owner-scoped CRUD/pagination, persistent bounded outbox, authenticated delivery, retries and pinned destination checks; real webhook regression. Upstream TCK push tests are not counted as qualified coverage for the newer flat config shape. |
| §5 serialization/errors/versioning | Generated fields, aliases/nulls/enums/base64, scalar bounds, method-specific response checks, typed errors and ErrorInfo. The older TCK has documented version/profile conflicts. |
| §7 authentication and authorization | Explicit credential hooks and security-requirement selection; real OIDCC/Keycloak exchanges and separate inbound introspection. Token trust, scopes, tenant identity, revocation policy and endpoint access decisions belong to the host. |
| §8 Agent Cards | Discovery, cache/ETag headers, interface selection, authenticated extended card and optional JWS/JCS. Trust anchors and extension behavior belong to the host. |
| §9 JSON-RPC | ArborRPC envelopes with A2A validation, correlated IDs, typed errors and live SSE; official SDK in both directions and selected TCK. |
| §10 gRPC | Canonical generated messages/stubs and optional server macro; real HTTP/2 contracts and SDK unary/streaming interop. The pinned TCK's URL-to-authority handling prevents using it as a valid end-to-end gRPC qualification. |
| §11 HTTP+JSON | Canonical routes, tenant prefixes, query parameters, status/ErrorInfo responses and SSE; actual SDK peers. Older TCK mappings are excluded only with explicit recorded reasons. |
| §12 custom bindings | The shared dispatch, streaming, generated types and error mappings are reusable extension points. A custom binding requires its own specification and equivalent semantics; no unspecified custom wire protocol is advertised. |
| §13 deployment security | Library bounds and identity/destination checks are tested. Hosts configure HTTPS/mTLS listeners, trusted proxy headers, stable principals, credential storage, quotas, consent and audit handling. |

A protocol library cannot certify arbitrary host handlers, identity providers,
custom extensions, deployment networks or distributed business execution.
Custom persistence adapters must atomically commit snapshots and provide any
additional distributed guarantees the host needs. Restart recovery intentionally
does not replay external side effects.

Do not replace a failed upstream assertion with a local weaker assertion.
Retain the failure, compare it to the pinned canonical spec, record any exclusion
and keep that scope out of conformance claims. See `TESTING.md`.
