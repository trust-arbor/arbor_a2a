#!/usr/bin/env python3
"""Run pinned, real peers and retain scoped, source-bound qualification receipts."""
import argparse
import contextlib
import hashlib
import json
import os
from pathlib import Path
import signal
import socket
import subprocess
import time
import urllib.request
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
REPORTS = ROOT / 'reports'
MANIFEST = ROOT / 'test/conformance/upstream.json'


def run(args, **opts):
    return subprocess.run(args, cwd=ROOT, check=True, text=True, **opts)


def source_digest():
    inputs = []
    for folder in ['lib', 'dev', 'scripts', 'examples', 'test/support', 'test/conformance']:
        inputs += [p for p in (ROOT / folder).rglob('*') if p.is_file() and '__pycache__' not in p.parts]
    inputs += [ROOT / p for p in ['mix.exs', 'mix.lock', 'test/interop/package.json', 'test/interop/package-lock.json',
        'test/interop/sdk-client.mjs', 'test/interop/sdk-server.mjs']]
    h = hashlib.sha256()
    for p in sorted(inputs):
        h.update(str(p.relative_to(ROOT)).encode() + b'\0' + p.read_bytes() + b'\0')
    return h.hexdigest()


@contextlib.contextmanager
def service(command, log_name):
    with socket.socket() as sock:
        sock.bind(('127.0.0.1', 0))
        port = sock.getsockname()[1]
    with (REPORTS / log_name).open('w') as log:
        process = subprocess.Popen(command + [str(port)], cwd=ROOT, stdout=log, stderr=log, start_new_session=True)
        try:
            deadline = time.monotonic() + 45
            while time.monotonic() < deadline:
                if process.poll() is not None:
                    raise RuntimeError(f'{log_name}: service exited; inspect retained log')
                try:
                    with urllib.request.urlopen(f'http://127.0.0.1:{port}/.well-known/agent-card.json', timeout=1) as response:
                        if response.status == 200:
                            break
                except (OSError, ValueError):
                    time.sleep(.1)
            else:
                raise RuntimeError(f'{log_name}: readiness deadline exceeded')
            yield f'http://127.0.0.1:{port}'
        finally:
            if process.poll() is None:
                os.killpg(process.pid, signal.SIGTERM)
                try:
                    process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    os.killpg(process.pid, signal.SIGKILL)
                    process.wait(timeout=5)


def verify_junit(path, expected):
    cases = list(ET.parse(path).iter('testcase'))
    if not cases or any(c.find('failure') is not None or c.find('error') is not None for c in cases):
        raise RuntimeError('Conformance did not produce an all-passing selected test run')
    skipped = {c.attrib['name']: c.find('skipped').attrib.get('message', '') for c in cases if c.find('skipped') is not None}
    identities = [c.attrib.get('classname', '') + '::' + c.attrib['name'] for c in cases]
    if len(identities) != len(set(identities)):
        raise RuntimeError('Duplicate conformance test identity')
    if 'case_ids' in expected and sorted(identities) != sorted(expected['case_ids']):
        raise RuntimeError('Unexpected conformance test identities')
    if skipped != expected['allowed_skips'] or len(cases) != expected['test_count']:
        raise RuntimeError(f'Unexpected test inventory or skips: {len(cases)} cases, {skipped}')
    return {'passed': len(cases) - len(skipped), 'skipped': skipped, 'total': len(cases)}


def conformance(manifest):
    target = ROOT / '.upstream/tck'
    if not (target / '.git').exists():
        run(['git', 'clone', '--no-checkout', 'https://github.com/a2aproject/a2a-tck.git', str(target)])
        run(['git', '-C', str(target), 'checkout', '--detach', manifest['tck']['revision']])
    head = run(['git', '-C', str(target), 'rev-parse', 'HEAD'], capture_output=True).stdout.strip()
    dirty = run(['git', '-C', str(target), 'status', '--porcelain'], capture_output=True).stdout.strip()
    if head != manifest['tck']['revision'] or dirty:
        raise RuntimeError('TCK checkout must be clean at the pinned revision')
    venv = ROOT / '.venv'
    if not (venv / 'bin/python').exists():
        run(['uv', 'venv', '--python', '3.13', str(venv)])
    run(['uv', 'pip', 'install', '--python', str(venv / 'bin/python'), '--require-hashes', '-r', 'test/conformance/requirements.txt'])
    with service(['mix', 'run', 'dev/conformance_server.exs'], 'tck-server.log') as base:
        command = [str(venv / 'bin/python'), '-m', 'pytest']
        command += [str(target / p) for p in manifest['tck']['tests']]
        command += ['--sut-host', base, '--transport', 'jsonrpc', '-q', '--tb=short',
            '--junitxml', str(REPORTS / 'tck.xml'), '-o', 'asyncio_default_fixture_loop_scope=function']
        with (REPORTS / 'tck.log').open('w') as log:
            run(command, stdout=log, stderr=subprocess.STDOUT, timeout=120)
    return verify_junit(REPORTS / 'tck.xml', manifest['tck'])


def peer_result(command, log_name):
    result = run(command, capture_output=True, timeout=45)
    (REPORTS / log_name).write_text(result.stdout + result.stderr)
    return next(json.loads(line) for line in reversed(result.stdout.splitlines()) if line.startswith('{'))


def interop():
    results = []
    with service(['mix', 'run', 'dev/conformance_server.exs'], 'interop-elixir-server.log') as base:
        results.append(peer_result(['node', 'test/interop/sdk-client.mjs', base], 'sdk-client.log'))
    with service(['node', 'test/interop/sdk-server.mjs'], 'interop-sdk-server.log') as base:
        results.append(peer_result(['mix', 'run', 'dev/interop_client.exs', base], 'elixir-client.log'))
    if [(r['direction'], r['assertions']) for r in results] != [('sdk-client-to-elixir', 7), ('elixir-client-to-sdk', 6)]:
        raise RuntimeError('Interop did not produce the expected independent assertions')
    return results


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('kind', choices=['interop', 'conformance'])
    args = parser.parse_args()
    REPORTS.mkdir(exist_ok=True)
    manifest = json.loads(MANIFEST.read_text())
    before = source_digest()
    result = interop() if args.kind == 'interop' else conformance(manifest)
    if source_digest() != before:
        raise RuntimeError('Implementation inputs changed during qualification')
    receipt = {'kind': args.kind, 'source_sha256': before, 'manifest_sha256': hashlib.sha256(MANIFEST.read_bytes()).hexdigest(),
        'result': result, 'scope': 'selected scenarios; not full A2A certification'}
    (REPORTS / f'{args.kind}-receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps(receipt, indent=2))


if __name__ == '__main__':
    main()
