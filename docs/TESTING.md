# Testing and upstream tracking

Run the README's local commands before changing protocol behavior. ExUnit
contracts exercise validation, task isolation, transitions, pagination, auth
failures, socket bounds and callback cleanup. StreamData properties cover ID
round trips and SSE chunk boundaries. Protocol-specific checks wrap shared
ArborRPC mechanics; no second JSON-RPC envelope implementation is introduced.

`scripts/qualify.py interop` starts owned Elixir and official JavaScript SDK
services on loopback, drives each with the other client, requires the expected
assertions, and terminates its services. It requires `npm ci --prefix
test/interop --ignore-scripts --no-audit --no-fund` first. Node 24+ is the tested
runtime. There is no SDK-absent success/skip fallback.

`scripts/qualify.py conformance` checks out the exact official TCK revision,
rejects a dirty/wrong checkout, installs hash-locked Python dependencies in
`.venv`, starts the Elixir fixture, and runs the original selected tests. Git,
uv and Python 3.13 are required. The generated peer's Agent Card describes only
implemented capabilities. Qualification fails on a failing test, missing test
inventory, unknown skip, changed skip reason or changed implementation inputs.
The only reviewed skip is documented in COVERAGE.md.

Successful runs retain source-bound JSON receipts and raw peer/TCK logs in
`reports/`. Conformance also retains JUnit XML. The source digest covers runtime,
fixture, runner, lock and peer-script inputs. It does not turn a selected test
run into full protocol certification. `scripts/tests` contains regression tests
for the evidence gate itself.

`scripts/check_package.py` builds an archive and compiles a fresh production
consumer from the extracted package. It rejects repository-tooling leakage and
checks that RPC/client APIs work without optional OIDCC, Bandit or StreamData.

`scripts/check_sources.py` verifies the pinned proto/prose/license snapshot
hashes offline. Add `--upstream` to check the latest published spec release,
observed specification main revision, official TCK head and official SDK version
against reviewed baselines. CI runs
this weekly and on manual dispatch. Network failures and detected changes fail
the check for review. Adoption requires source/requirement review and fresh
qualification; the checker never rewrites pins or implementation code.

The observed main revision is a drift-review baseline, not a qualified protocol
target; the released v1.0.1 sources remain pinned separately. Building a complete
clause register remains assurance work. The official schema is a generated
artifact; the vendored canonical proto is the normative data-model input.
