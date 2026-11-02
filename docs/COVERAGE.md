# Protocol coverage and evidence

Target: A2A **v1.0.1**, canonical commit
[`3303592588e388e62e0f69f701af531d2f4e3991`](https://github.com/a2aproject/A2A/tree/3303592588e388e62e0f69f701af531d2f4e3991),
protocol **1.0**. The source manifest records exact peer revisions and selected
case identities. Canonical proto/prose/license snapshots remain frozen under
`test/fixtures/spec/`; generated derivatives retain upstream licensing.

“Implemented” below describes named library behavior. Test evidence is scoped;
it is not exhaustive certification of every normative clause or host deployment.
The [requirements tracker](REQUIREMENTS.md) separates library and host duties.

| Scope | Status | Evidence and boundaries |
| --- | --- | --- |
| JSON-RPC envelopes/errors (§5, §9) | Implemented | ArborRPC reuse, strict envelope/ID checks, canonical codes and ErrorInfo; contracts, original TCK and SDK peers. |
| ProtoJSON/model validation (§4–5) | Implemented | Generated canonical messages and schema-aware validation; aliases, null/Value, enum numbers, integer strings, base64 variants, required fields and unknown-field compatibility. Semantic contracts and binary null regression supplement protobuf validation. |
| SendMessage/direct/task (§3.1.1) | Implemented | Blocking/immediate behavior, handler validation, input/output mode negotiation, caller/context binding; server/execution regressions and actual peers. Hosts choose business output and skill behavior. |
| Get/List/CancelTask (§3.1.3–5) | Implemented | History projection, nanosecond ordering, filters, owner-bound pagination, terminal guards, host cancellation acknowledgement or owned-worker termination. |
| Multi-turn/lifecycle (§3.4) | Implemented | Context inference, mismatch/terminal rejection and per-task execution leases. Managed work fails on crash/timeout/restart without replay. External side effects remain host-owned. |
| Streaming/subscriptions (§3.1.2, §3.1.6) | Implemented | Live SSE and gRPC, atomic initial snapshots, status/artifact updates, assembly/appends, terminal closure, bounded queues and reader cleanup. Contracts, original TCK and actual SDK peers. No replay guarantee. |
| Persistent state/execution | Implemented local adapter and behaviour | Atomic private snapshots retain records, configs, outbox and cursor keys. Store/worker ownership and recovery regressions. Distributed storage/consensus and business-effect recovery are host adapters/policy. |
| Push notifications (§3.1.7–10) | Implemented, opt-in | Owner-scoped CRUD/pagination, bounded persistent outbox, authentication, retries, public HTTPS/DNS/IP policy and pinned address/TLS host. Real webhook tests; older TCK config profile is not counted as qualified coverage. |
| Public/extended/signed cards (§8, §3.1.11) | Implemented, signing/extended opt-in | Discovery, cache/ETag/Last-Modified headers, authenticated extended card, optional JWS/JCS verification with explicit trusted keys; card, signature and TCK regressions. |
| Extension negotiation | Implemented framework | Exact URI/version negotiation, required-support errors, active extension header/context. Hosts implement the extensions they advertise; no unspecified custom extension is claimed. |
| Version handling (§3.6) | Implemented | 1.0 only, patch ignored, missing/empty version treated as unsupported 0.3. No silent downgrade. |
| Auth/OIDC (§7, §13) | Implemented integration boundary | Security-requirement selection, credential callbacks, generic HTTP auth, API-key headers and mutual TLS. Direct OIDCC and real digest-pinned Keycloak: client credentials, code/S256, refresh, introspection and principal isolation. Host policy supplies trusted issuers, resources, scopes and authorization. |
| HTTP+JSON (§11) | Implemented | Client and Plug canonical routes, tenant prefixes, query parameters, typed status/ErrorInfo and SSE. JSON and A2A media negotiation; original compatible TCK assertions and SDK in both directions. |
| gRPC (§10) | Implemented, server dependency opt-in | Canonical generated types/stubs, shared server dispatch and errors/streams; real HTTP/2 contracts and independent SDK client. Pinned TCK URL handling is incompatible; see TESTING.md. |
| Custom bindings (§12) | Extension boundary | Shared dispatch/streams/models/errors are available. An actual custom wire protocol requires a host specification and qualification; none is advertised. |

## Qualification limits

Local verification on 2026-11-02 passed **170 tests plus two properties** on
Elixir 1.17.3/OTP 27.0.1 and Elixir 1.20.5/OTP 29.1.2, five Python evidence-gate
regressions, strict compile/Credo/docs/formatting, runnable examples, cold archive
installation and workflow lint. Canonical protobuf regeneration was byte-identical.
All final peer receipts share source digest
`cff0c241478add0ea46f5378573537aebd0744a1c444200cd5684b70df01003c`.
These were the initial local runs. The first GitHub CI run passed both Elixir
matrix jobs and the protocol conformance/interop lanes, but exposed a Linux
permission error in the Keycloak import fixture before authentication assertions
could run. The fixture now permits its non-root image user to read the import,
detects container exit without waiting out readiness, and retains startup logs.
Authentication assertion counts and protocol coverage are unchanged.

The baseline original TCK lane contains **25 cases: 24 pass, one reviewed
HTTP-content-type skip**. The expanded lane selects **157 original assertions**
for public cards, core JSON-RPC/REST operations, data models and streaming.
These lanes overlap; do not add their counts as unique requirements.

The TCK pins **v1.0.0**, not our v1.0.1 source. Three conflicting cases are
excluded from the expanded profile with explicit reasons in the manifest:
its generic unsupported-media requirement lacks `expected_error` in two
bindings, and its REST cancellation validator expects 409 where canonical
v1.0.1 §5.4 specifies 400. Its gRPC transport passes an absolute interface URL
directly to DNS; gRPC is qualified separately with real peers. The original
assertions are not patched. Unconfigured capability/transport skips are not
counted as passing assertions.

Independent SDK evidence covers original core calls in both directions,
JSON-RPC streaming, SDK clients against REST/gRPC, and Elixir clients against
SDK JSON-RPC/REST/SSE. gRPC's peer fixture explicitly converts an advertised URL
to an authority for grpc-js, without modifying the SDK. Real IdP evidence covers
one configured Keycloak profile, not every provider or OAuth/OIDC flow.

There is no open implementation placeholder for the named standard-operation
surface. Future work includes wider independent-provider qualification, newer
compatible official TCK adoption, deployment-specific distributed adapters and
individually specified extensions/custom bindings. Weekly source checks detect
drift without advancing reviewed pins automatically.
