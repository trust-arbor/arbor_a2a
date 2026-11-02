#!/usr/bin/env python3
"""Qualify direct OIDCC with an owned, digest-pinned Keycloak container."""
import contextlib
import json
import subprocess
import tempfile
import time
import urllib.request
from pathlib import Path
from qualify import ROOT, REPORTS, MANIFEST, run, source_digest

IMAGE = json.loads(MANIFEST.read_text())['auth']['keycloak_image']
RESOURCE = 'https://agent.example.test/a2a'


def wait_for_keycloak(name, issuer, timeout=120):
    deadline = time.monotonic() + timeout
    while True:
        try:
            with urllib.request.urlopen(issuer + '/.well-known/openid-configuration', timeout=2) as response:
                assert response.status == 200
                return
        except OSError:
            state = json.loads(run(['docker', 'inspect', '--format', '{{json .State}}', name], capture_output=True).stdout)
            if not state['Running']:
                raise RuntimeError(f"Keycloak exited before readiness (exit={state['ExitCode']}, OOMKilled={state['OOMKilled']}); inspect reports/auth-keycloak.log") from None
            if time.monotonic() > deadline:
                raise RuntimeError('Keycloak readiness deadline exceeded; inspect reports/auth-keycloak.log') from None
            time.sleep(.25)


@contextlib.contextmanager
def keycloak():
    import uuid
    name = 'arbor-a2a-auth-' + uuid.uuid4().hex[:12]
    with tempfile.TemporaryDirectory(prefix='arbor-a2a-') as directory:
        mapper = {'name': 'audience', 'protocol': 'openid-connect', 'protocolMapper': 'oidc-audience-mapper',
                  'config': {'included.custom.audience': RESOURCE, 'access.token.claim': 'true'}}
        common = {'protocol': 'openid-connect', 'clientAuthenticatorType': 'client-secret', 'enabled': True, 'publicClient': False, 'standardFlowEnabled': True,
                  'serviceAccountsEnabled': True, 'directAccessGrantsEnabled': False, 'defaultClientScopes': ['basic'],
                  'redirectUris': ['http://127.0.0.1:4180/callback'], 'protocolMappers': [mapper, {'name': 'introspection-audience', 'protocol': 'openid-connect', 'protocolMapper': 'oidc-audience-mapper', 'config': {'included.client.audience': 'resource', 'access.token.claim': 'true'}}]}
        realm = {'realm': 'arbor-a2a', 'enabled': True, 'sslRequired': 'none',
                 'clients': [dict(common, clientId='caller', secret='fixture-caller', attributes={'pkce.code.challenge.method': 'S256'}), dict(common, clientId='resource', secret='fixture-resource')],
                 'users': [{'username': 'alice', 'enabled': True, 'emailVerified': True,
                            'firstName': 'Alice', 'lastName': 'Fixture', 'email': 'alice@example.test',
                            'credentials': [{'type': 'password', 'value': 'fixture-password', 'temporary': False}]}]}
        realm_file = Path(directory, 'realm.json')
        realm_file.write_text(json.dumps(realm))
        # These are fake fixture credentials. The image runs as UID 1000,
        # which differs from the Linux runner's owner of the 0700 temp dir.
        Path(directory).chmod(0o755)
        realm_file.chmod(0o644)
        try:
            run(['docker', 'run', '--detach', '--name', name, '--memory', '1g', '--cpus', '2',
                 '--env', 'JAVA_OPTS_APPEND=-Xms64m -Xmx384m -XX:ActiveProcessorCount=2', '--publish', '127.0.0.1::8080',
                 '--volume', directory + ':/opt/keycloak/data/import:ro', IMAGE, 'start-dev', '--import-realm', '--hostname-strict=false'], capture_output=True)
            address = run(['docker', 'port', name, '8080/tcp'], capture_output=True).stdout.strip()
            issuer = 'http://' + address + '/realms/arbor-a2a'
            wait_for_keycloak(name, issuer)
            yield issuer
        finally:
            try:
                logs = subprocess.run(['docker', 'logs', name], cwd=ROOT, capture_output=True, text=True, timeout=30)
                REPORTS.mkdir(exist_ok=True)
                (REPORTS / 'auth-keycloak.log').write_text(logs.stdout + logs.stderr)
            finally:
                subprocess.run(['docker', 'rm', '--force', name], cwd=ROOT, capture_output=True, timeout=30)


def main():
    REPORTS.mkdir(exist_ok=True)
    if not (ROOT / '.venv/bin/python').exists():
        run(['uv', 'venv', '--python', '3.13', str(ROOT / '.venv')])
    before = source_digest()
    with keycloak() as issuer:
        result = subprocess.run(['mix', 'run', 'dev/auth_interop.exs', issuer], cwd=ROOT, capture_output=True, text=True, timeout=120)
        (REPORTS / 'auth-interop.log').write_text(result.stdout + result.stderr)
        if result.returncode:
            raise RuntimeError('OIDCC qualification failed; inspect retained private log')
        receipt = next(json.loads(line) for line in result.stdout.splitlines() if line.startswith('{'))
        if receipt != {'assertions': 12, 'peer': 'Keycloak', 'oidcc': '3.9.0'}:
            raise RuntimeError('Unexpected authentication qualification inventory')
    if before != source_digest():
        raise RuntimeError('Source changed during qualification')
    (REPORTS / 'auth-receipt.json').write_text(json.dumps({'source_sha256': before, 'image': IMAGE, 'result': receipt}, indent=2) + '\n')
    print(json.dumps(receipt))

if __name__ == '__main__':
    main()
