# Protocol coverage and remaining work

Target: A2A specification **v1.0.1**, commit
[`3303592588e388e62e0f69f701af531d2f4e3991`](https://github.com/a2aproject/A2A/tree/3303592588e388e62e0f69f701af531d2f4e3991),
protocol version `1.0`, JSON-RPC binding. Canonical proto and prose snapshots,
license and SHA-256 values live in `test/fixtures/spec/`. The source manifest
in `test/conformance/upstream.json` records qualified peer revisions separately.
These are scoped implementation bundles, not an exhaustive normative inventory.

| Scope | Status | Executable evidence / remaining work |
| --- | --- | --- |
| JSON-RPC envelopes and error codes (§9, §5.4) | Implemented initial scope | `protocol_test.exs`; official TCK selected error-code/ErrorInfo tests. ID correlation, malformed/mixed envelopes and unknown methods are checked. |
| Agent Card discovery/interface selection (§8) | Implemented initial scope | `types_test.exs`, `http_test.exs`; six official card tests; actual SDK discovery. Public same-origin JSON-RPC only. |
| Messages/parts/tasks (§4.1) | Partial | `types_test.exs`, `protocol_test.exs`, `request_alias_test.exs`; text/raw/URL/data validation, implemented request field aliases, protected metadata/data dictionaries and state checks. Full ProtoJSON normalization, all fields and schema obligations need a separate inventory. |
| SendMessage/direct response/task (§3.1.1) | Implemented initial scope | `server_test.exs`, `http_test.exs`; official SDK in both directions. Host owns execution and output negotiation beyond the current callback contract. |
| GetTask/history (§3.1.3, §3.2.4) | Implemented initial scope | Contract tests, six selected official TCK history tests and SDK retrieval; task identity, inaccessible-task errors and history projection. |
| ListTasks (§3.1.4) | Implemented initial scope | Filter/pagination contracts and SDK listing; newest-status-time ordering, explicit empty artifacts when requested, signed caller/filter-bound sort-key cursors. Live pagination, no snapshot promise. |
| CancelTask (§3.1.5) | Implemented initial scope | Contract tests; terminal-task error; optional host cancellation acknowledgement before state mutation. Host stops actual background work. |
| Context/multi-turn identity (§3.4) | Implemented initial scope | Resume interrupted task, infer matching context, reject mismatches and terminal-task continuation. |
| Version negotiation (§3.6) | Implemented initial scope | HTTP contracts and selected TCK version error. Only 1.0 advertised; missing/empty version represents unsupported 0.3; patch does not change negotiation. |
| Authentication/authorization (§7) | Host integration only | Real HTTP bearer-hook partition tests and fail-closed callbacks. Full OAuth/OIDC flow selection and real IdP tests remain open. See AUTHENTICATION.md. |
| SendStreamingMessage/SubscribeToTask (§3.1.2, §3.1.6) | Not implemented | SSE codec property/limit tests are preparation only. Need real streaming, task snapshots/updates, disconnect/terminal cleanup and independent interop. Capability is absent. |
| Push notifications (§3.1.7–10) | Not implemented | Explicit unsupported errors tested. Need persistent config, outbound destination policy, delivery authentication, retries and lifecycle before advertising. |
| Extended/signed Agent Cards (§3.1.11, §8.4) | Not implemented | Unsupported extended-card error. Need separate authenticated card and signature verification/canonicalization before adoption. |
| Required extensions | Not implemented | Server config rejects declaring required extensions. Header/extension negotiation and individual extension contracts remain open. |
| gRPC/HTTP+JSON/custom bindings | Not implemented | No interfaces advertised. ArborRPC reuse applies to the JSON-RPC binding. |
| Durable/distributed task execution | Not implemented | Process-local bounded store only; persistence, store adapters, restart recovery and cross-node semantics remain open. |

## Evidence limits

The selected official TCK lane runs 25 original test cases: 24 pass and one
explicitly reviewed case skips because wrong HTTP Content-Type is rejected with
HTTP 415 before JSON-RPC dispatch. This skip is visible and exact-match gated.
The TCK itself pins v1.0.0 source at
`173695755607e884aa9acf8ce4feed90e32727a1`, not our v1.0.1 target. Its selected
card/error/history checks are supplementary evidence; they do not qualify every v1.0.1
change. We do not patch the upstream tests or count unexecuted scenarios as
passing. The upstream aggregate report includes unrun requirements in its
denominator; use retained JUnit and our scoped receipt for selected results.

The pinned official JavaScript SDK 1.3.0 lane exercises discovery, direct/task
responses, retrieval/history, listing, and missing-task errors across actual
HTTP in both directions. It is not a proof of complete SDK equivalence. Local
contract/property tests cover forbidden alternatives and bounds. Tests are
evidence for named behavior, not a substitute for a full requirement inventory.

## Next implementation sequence

1. Inventory remaining proto/prose clauses and finish client/server result,
   field and media/output negotiation validation.
2. Qualify and complete task lifecycle/concurrency, durable storage contracts
   and host background-work ownership.
3. Implement streaming and subscriptions with bounded delivery, cancellation,
   terminal cleanup and official SDK/TCK evidence.
4. Add explicit Agent Card auth selection and direct OIDCC flows; qualify a
   real AS/IdP while preserving separate incoming token verification.
5. Adopt push notifications, signed/extended cards and additional bindings as
   separately qualified profiles.

Update this file, the source manifest and executable evidence whenever a
feature's status changes. Weekly upstream checks detect releases/tooling drift
without silently advancing qualified sources.
