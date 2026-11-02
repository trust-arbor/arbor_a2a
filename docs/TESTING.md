# Testing and qualification

Tests distinguish local contracts, original upstream conformance assertions,
independent implementation interop and application-owned policy. They do not
certify arbitrary handlers, extensions, providers or deployments.

## Local contracts

Run `mix test --warnings-as-errors`, strict compile, formatting, strict Credo and
docs warnings-as-errors. Contract/property tests cover envelopes, types and
ProtoJSON, state/identity/history/cursors, managed jobs and cancellation,
persistence/recovery, real HTTP/SSE, bounded subscriptions, webhook delivery,
card signatures/extensions and real TLS/mTLS. The gRPC test crosses HTTP/2 and
checks typed errors. Tests run on Elixir 1.17/OTP 27 and the current toolchain.

`check_package.py` builds a fresh archive and cold consumer. Optional OIDCC,
JOSE/signing, gRPC server/Cowboy and repository tooling are excluded by default.
`check_examples.py` runs the examples against actual HTTP. The dependency policy
check retains its exact documented optional-gRPC advisory acknowledgement.

## Original TCK

`qualify.py conformance` runs the original baseline **25 cases**, with **24 pass
and one exact reviewed skip**: wrong HTTP Content-Type is rejected with HTTP 415
before JSON-RPC dispatch. `qualify_profiles.py` runs **157 selected original
assertions** for the streaming JSON-RPC/HTTP+JSON profile. Scope overlaps the
baseline; counts are not additive.

The official TCK is pinned at
`d4d6fae7887f88ef607fb461c13e3b0e1802f19b` and itself targets spec v1.0.0
`173695755607e884aa9acf8ce4feed90e32727a1`. Our target is v1.0.1
`3303592588e388e62e0f69f701af531d2f4e3991`. Tests, fixtures and validators in
upstream are never patched. Hash-locked Python dependencies, clean exact
checkout checks, exact case identities and exact skip reasons guard the lanes.
Unexpected failure, error, skip, empty/replaced/duplicate inventory fails.

A broader diagnostic run exposed reviewed upstream conflicts:

- `test_must_requirement[CORE-SEND-003-jsonrpc]` and its HTTP+JSON counterpart:
  the requirement lacks `expected_error`, so its runner rejects the correct
  `ContentTypeNotSupportedError` as an operation failure.
- `test_cancel_terminal_task_returns_error[http_json]`: its validator expects
  HTTP 409; our canonical v1.0.1 §5.4 requires HTTP 400.
- gRPC: its client passes the advertised absolute URL directly to
  `grpc.insecure_channel`, producing a DNS error. Canonical interface URLs
  remain valid absolute URLs; the library does not emit an invalid card to
  accommodate that fixture.

Those conflicting cases are outside the selected qualification profile and
recorded in the source manifest. Unconfigured push/extended-card scopes and
transport skips do not count as passes. The TCK's aggregate percentage counts
unexecuted requirements in its denominator; retained scoped JUnit and receipts
are the evidence. Do not advertise its aggregate as protocol certification.

## Independent SDK peers

`@a2a-js/sdk` **1.3.0** is pinned with npm integrity. Real listeners/sockets are
used in both directions. The original lane has seven SDK-client and six
Elixir-client assertions. The expanded lane adds five JSON-RPC stream
assertions, ten SDK-to-REST/gRPC assertions, and eight Elixir-to-SDK
JSON-RPC/REST/SSE assertions. gRPC's host fixture converts the card URL to an
authority for grpc-js; it does not change SDK internals or TCK assertions.
Generated SDK `.fromJSON` constructors populate protobuf defaults rather than
passing incomplete typed objects to its wire encoder.

Services bind loopback ephemeral ports, have readiness/operation deadlines and
are terminated only through owned process groups. Missing peer tools fail;
there is no mock or skip fallback. Receipts bind runtime/peer inputs and the
manifest SHA-256; source changes during qualification invalidate the run.

## Real IdP/AS

`qualify_auth.py` owns a digest-pinned Keycloak 26.8.1 container. Direct OIDCC 3.9.0
performs client credentials, real browser-form authorization code with required
S256, ID-token validation and refresh. Separate resource-server introspection
checks issuer/resource/time/subject, rejects missing/forged credentials and
isolates task ownership. Twelve assertions are required. This qualifies one
provider configuration, not all OAuth/OIDC providers and flows. Fixtures retain
private logs only under ignored reports and never emit tokens in receipts.
The import fixture has explicit directory/file permissions so Keycloak's
non-root user can read it on Linux as well as Docker Desktop. Readiness fails
immediately if the owned container exits, and `reports/auth-keycloak.log` is
retained before cleanup, including on startup failure. This fixture correction
does not change or skip any of the twelve authentication assertions. The browser
login helper uses the absolute repository virtual-environment interpreter and
script paths, so it does not depend on a developer's executable search path.

## Keeping evidence current

`check_sources.py --upstream` compares the latest spec release, tracked spec
main, official TCK and SDK with reviewed pins; scheduled CI runs weekly and can
be dispatched manually. It does not update dependencies or baselines silently.
`check_requirements.py` inventories all 163 normative prose blocks in the frozen
source without claiming individual certification. The canonical proto generates
wire types through `generate_proto.py` with protobuf 0.17.1; the Apache license
is included in the package. Run all applicable lanes after behavior changes and
update coverage, requirements and manifest together.
