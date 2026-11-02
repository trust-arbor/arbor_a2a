# Dependency security

The optional gRPC server uses `grpc_server` 1.0.5 and Cowboy 2.20.0. Its
Cowlib 2.21.0 dependency is listed under **EEF-CVE-2026-43966** / CVE-2026-43966:
structured-field serialization can emit untrusted CR/LF bytes.

The [published advisory](https://osv.dev/vulnerability/EEF-CVE-2026-43966)
identifies Cowboy **2.16.0 and later** as protected on the server side by the
`invalid_response_headers: error_terminate` default. ArborA2A constrains the
optional Cowboy dependency to at least that version and does not construct
structured response fields from untrusted data. Hosts must retain that header
validation policy. The gRPC server and Cowboy are absent from the default cold
package consumer.

The root project acknowledges exactly this advisory in `mix.exs`; `mix hex.audit`
continues to list it in its ignored section. `scripts/check_dependency_policy.py`
checks the resolved Cowboy version and vendor guard, then runs the audit so
other advisories and retirements fail CI. This is a documented mitigation, not a
claim that Cowlib has no advisory. Remove the acknowledgement after an updated
release resolves it. Consumers enabling the optional server make their own
dependency-policy decision; this root acknowledgement is not their policy.

Run the policy check and `npm audit --prefix test/interop` after dependency changes.
Canonical protocol snapshots and generated derivatives retain Apache-2.0
attribution under `priv/licenses/`; repository-only peer tooling is not packaged.
