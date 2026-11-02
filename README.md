# ArborA2A

An Elixir A2A client and Plug server following the ArborMCP, ArborRPC and
ArborACP conventions: `Arbor.A2A.*` modules, supervised processes, explicit
ownership, and `{:ok, value}` / `{:error, reason}` results.

This is an initial implementation targeting **A2A v1.0.1, protocol 1.0,
JSON-RPC over HTTP**. It is not a complete A2A implementation or a certified
release. [Coverage and remaining work](docs/COVERAGE.md) distinguish working
features, selected executable evidence and unimplemented protocol obligations.

Implemented foundations:

- Public Agent Cards and same-origin JSON-RPC interface discovery.
- `SendMessage` with direct replies or tasks, task retrieval/listing, multi-turn
  context binding, history projection and host-acknowledged cancellation.
- Principal/tenant-partitioned, bounded task storage with authenticated pagination.
- Canonical errors and ErrorInfo, version handling, strict RPC envelope checks.
- A finite Mint client and host-mounted Plug endpoint with explicit auth hooks.
- A bounded SSE codec, ready for subsequent streaming transport work.

Streaming operations, subscriptions, push delivery, extended/signed cards,
gRPC/REST bindings and complete OAuth/OIDC profiles remain future work. Those
optional server capabilities are not advertised; requests receive explicit errors.

## Run the example

Requires Elixir 1.17+ and OTP 27+ (OIDCC's runtime floor). From this checkout:

```sh
mix deps.get
mix run examples/echo_server.exs
```

In another terminal:

```sh
mix run examples/client.exs
```

Or use the client directly:

```elixir
{:ok, client} = Arbor.A2A.Client.new("http://127.0.0.1:4180/a2a")
{:ok, reply} = Arbor.A2A.Client.send_message(client, Arbor.A2A.Message.text("Hello"))
```

Bandit is example/test tooling; library consumers mount `Arbor.A2A.HttpPlug` in
their own listener. HTTPS is required by the built-in client except for explicit
loopback development URLs. The initial task store is process-local and loses
tasks on restart. An unauthenticated service uses one shared anonymous partition.

## Development and qualification

```sh
mix format --check-formatted
mix compile --warnings-as-errors
mix test --warnings-as-errors
mix credo --strict
python3 -B -m unittest discover -s scripts/tests -v
python3 -B scripts/check_sources.py
python3 -B scripts/check_package.py
python3 -B scripts/check_examples.py
npm ci --prefix test/interop --ignore-scripts --no-audit --no-fund
python3 -B scripts/qualify.py interop
python3 -B scripts/qualify.py conformance
mix docs --warnings-as-errors
```

The peer lanes use real loopback HTTP, the official JavaScript SDK 1.3.0 and
unmodified selected official TCK tests. Conformance requires Git, uv and Python
3.13; interop requires Node 24+. Missing tools and unexpected skips fail the
qualification command. Reports are retained in `reports/` and CI artifacts.
See [testing](docs/TESTING.md) for the exact scope and the TCK revision mismatch.

## Design and authentication

ArborRPC owns JSON-RPC envelopes; this library owns A2A validation, method
semantics and HTTP adaptation. OAuth/OIDC is separate from RPC. Hosts can call
OIDCC directly through the token-provider boundary; a shared `arbor_oauth`
facade is not required. Incoming API access tokens need an independent verifier
and application authorization policy. See [architecture](docs/ARCHITECTURE.md),
[authentication](docs/AUTHENTICATION.md) and [usage rules](usage-rules.md).

No Hex release has been published. Dependency `arbor_rpc` is pinned to the
published `1.0.0-rc.4`; local source paths are not required by the package.
