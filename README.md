# ArborA2A

An Elixir implementation of **A2A v1.0.1 / protocol 1.0**, following the
ArborMCP, ArborRPC and ArborACP conventions: `Arbor.A2A.*`, explicit supervision,
caller ownership and tuple results. The API is experimental; no release has
been published. See [coverage](docs/COVERAGE.md) and
[requirements](docs/REQUIREMENTS.md) for qualified scope and evidence limits.

Features include:

- JSON-RPC and HTTP+JSON clients and Plug endpoints; generated protobuf types,
  gRPC client stubs and an optional gRPC server binding.
- Direct messages, multi-turn tasks, history projection, filtering, authenticated
  cursor pagination and caller/tenant isolation.
- Managed asynchronous work with blocking or immediate responses, cancellation,
  crash/timeout handling and restart recovery without replaying business work.
- Live SSE and gRPC streams, task subscriptions, artifact updates and bounded
  subscriber queues. Disconnecting a reader does not cancel its task.
- Optional atomic disk persistence for task records, webhook configuration,
  notification outbox and cursor keys; a persistence behaviour for host adapters.
- Authenticated webhook delivery, bounded retries, DNS/IP destination policy,
  address pinning, TLS verification and redirect rejection.
- Public and authenticated extended Agent Cards, caching/ETags, optional JWS
  signing/verification with RFC 8785 canonicalization, and extension negotiation.
- Canonical errors, ErrorInfo, version negotiation, generated schema validation
  and ProtoJSON normalization, including field aliases and arbitrary Value data.
- Per-request credential providers, HTTP authentication, custom API-key headers
  and mutual TLS. OAuth/OIDC uses OIDCC directly; no shared OAuth facade is needed.

The official JavaScript SDK is exercised over real HTTP/SSE and gRPC. Unmodified
upstream TCK tests are reused; the pinned TCK targets v1.0.0, so reviewed
incompatibilities with v1.0.1 are documented rather than changing our protocol
behavior. These checks do **not** constitute complete protocol certification.

## Run the examples

Requires Elixir 1.17+ and OTP 27+:

```sh
mix deps.get
mix run examples/echo_server.exs
# In another terminal:
mix run examples/client.exs
```

```elixir
alias Arbor.A2A.{Client, Message}
{:ok, client} = Client.new("http://127.0.0.1:4180/a2a")
{:ok, reply} = Client.send_message(client, Message.text("Hello"))

# An HTTP+JSON interface uses the same API:
{:ok, rest} = Client.new("https://agent.example/rest", binding: :rest)
```

For managed work and streaming, see `examples/managed_server.exs` and
`examples/stream_client.exs`. Bandit is example/test tooling; consumers mount
the Plug in their own listener. HTTPS is required except for loopback development
URLs. An unauthenticated service shares one anonymous task partition.

The default store is bounded memory. To survive restarts, supervise a store with:

```elixir
{Arbor.A2A.TaskStore,
 name: MyApp.Tasks,
 persistence: {Arbor.A2A.TaskStore.File, "/private/app-data/a2a.snapshot"}}
```

The local file adapter supports one writer. Distributed consensus, business
side-effect recovery, credential provisioning, listener TLS and application
access policy belong to the host. [Architecture](docs/ARCHITECTURE.md) explains
these boundaries. [Authentication](docs/AUTHENTICATION.md) shows direct OIDCC
integration. [Dependency security](docs/DEPENDENCY_SECURITY.md) records the
optional gRPC dependency mitigation.

## Development

```sh
mix format --check-formatted
mix compile --warnings-as-errors
mix test --warnings-as-errors
mix credo --strict
mix docs --warnings-as-errors
python3 -B -m unittest discover -s scripts/tests -v
python3 -B scripts/check_sources.py
python3 -B scripts/check_dependency_policy.py
python3 -B scripts/check_package.py
python3 -B scripts/check_examples.py
npm ci --prefix test/interop --ignore-scripts --no-audit --no-fund
python3 -B scripts/qualify.py interop
python3 -B scripts/qualify.py conformance
python3 -B scripts/qualify_profiles.py
python3 -B scripts/qualify_auth.py
```

Qualification needs Node 24+, Git, uv and Python 3.13; real provider qualification
also needs Docker. Missing tools, changed peer revisions, unexpected case
inventories and unreviewed skips fail their lanes. Reports are kept in ignored
`reports/` and CI artifacts. See [testing](docs/TESTING.md).

ArborRPC owns JSON-RPC mechanics. This library owns A2A semantics; its published
`arbor_rpc` dependency remains pinned to `1.0.0-rc.4`.
