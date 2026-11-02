# Repository guidance

ArborA2A is an Elixir A2A implementation using namespace `Arbor.A2A.*` and Hex
application `arbor_a2a`. Follow the tuple-return, explicit-supervision and
layering conventions in ArborMCP, ArborRPC and ArborACP. The target is pinned
A2A 1.0.1: JSON-RPC, HTTP+JSON and the optional gRPC binding. Custom bindings
and host-specific extensions require their own specifications and evidence.

- Keep shared JSON-RPC mechanics in ArborRPC and A2A validation/semantics here.
- Use existing OIDCC APIs before proposing another authentication facade.
- Keep caller/tenant/resource credentials and task records isolated.
- Reuse official conformance tests without weakening assertions. Keep
  conformance, independent interop, contracts and host duties distinct.
- Update README, docs/COVERAGE.md and test/conformance/upstream.json with
  behavior and evidence changes. Do not mark untested scopes complete.
- Regenerate protocol modules from the pinned proto with `scripts/generate_proto.py`;
  retain the upstream Apache-2.0 license in the package.
- Never commit `.upstream`, virtual environments, credentials, generated peer
  dependencies or private logs. Preserve upstream snapshot licensing.
- Run formatting, strict compile, ExUnit, strict Credo, Python gate tests,
  source checks and applicable interop/conformance lanes. Build docs with
  warnings as errors. Root packaging excludes dev/test tooling.
- Public API is currently experimental. Document changes and keep examples
  executable; do not publish or release packages as part of ordinary edits.
