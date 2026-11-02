#!/usr/bin/env python3
"""Run reviewed original TCK assertions and independent expanded peer lanes."""
import argparse
import hashlib
import json
import subprocess
from qualify import ROOT, REPORTS, MANIFEST, service, source_digest, run, verify_junit, peer_result, verify_sdk

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--kind', choices=['all','conformance','interop'], default='all')
    args = parser.parse_args()
    REPORTS.mkdir(exist_ok=True)
    manifest = json.loads(MANIFEST.read_text())
    profile = manifest['profiles']['standard_bindings']
    if args.kind in ['all', 'interop']:
        verify_sdk(manifest)
    target = ROOT / '.upstream/tck'
    if not (target / '.git').exists():
        run(['git','clone','--no-checkout','https://github.com/a2aproject/a2a-tck.git',str(target)])
        run(['git','-C',str(target),'checkout','--detach',manifest['tck']['revision']])
    if run(['git','-C',str(target),'rev-parse','HEAD'],capture_output=True).stdout.strip() != manifest['tck']['revision'] or run(['git','-C',str(target),'status','--porcelain'],capture_output=True).stdout.strip():
        raise RuntimeError('TCK must be clean at the reviewed revision')
    if not (ROOT / '.venv/bin/python').exists():
        run(['uv','venv','--python','3.13',str(ROOT/'.venv')])
    run(['uv','pip','install','--python',str(ROOT/'.venv/bin/python'),'--require-hashes','-r','test/conformance/requirements.txt'])
    before = source_digest()
    results = {}
    with service(['mix','run','dev/full_conformance_server.exs'],'profiles-server.log') as base:
        if args.kind in ['all','conformance']:
            command=[str(ROOT/'.venv/bin/python'),'-m','pytest']+[str(target/p) for p in profile['tests']]
            command+=['--sut-host',base,'--transport',','.join(profile['transports']),'-q','--tb=short','--junitxml',str(REPORTS/'profiles-tck.xml'),'-o','asyncio_default_fixture_loop_scope=function']
            with (REPORTS/'profiles-tck.log').open('w') as log:
                run(command,stdout=log,stderr=subprocess.STDOUT,timeout=180)
            results['conformance']=verify_junit(REPORTS/'profiles-tck.xml',profile)
        if args.kind in ['all','interop']:
            results['stream_peer']=peer_result(['node','test/interop/sdk-stream-client.mjs',base],'profiles-sdk-stream.log')
            results['bindings_peer']=peer_result(['node','test/interop/sdk-bindings-client.mjs',base],'profiles-sdk-bindings.log')
            if results['stream_peer'] != {'direction':'sdk-stream-client-to-elixir','assertions':5} or results['bindings_peer'] != {'direction':'sdk-bindings-to-elixir','assertions':10}:
                raise RuntimeError('Unexpected independent peer inventory')
    if args.kind in ['all','interop']:
        with service(['node','test/interop/sdk-server.mjs'],'profiles-sdk-server.log') as base:
            results['elixir_peer']=peer_result(['mix','run','dev/bindings_client.exs',base],'profiles-elixir-bindings.log')
            if results['elixir_peer'] != {'direction':'elixir-bindings-to-sdk','assertions':8}:
                raise RuntimeError('Unexpected reverse peer inventory')
    if source_digest() != before:
        raise RuntimeError('Implementation changed during qualification')
    receipt={'source_sha256':before,'manifest_sha256':hashlib.sha256(MANIFEST.read_bytes()).hexdigest(),'result':results,'scope':'reviewed selected assertions; see manifest conflicts and docs/TESTING.md'}
    (REPORTS/f'profiles-{args.kind}-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
    print(json.dumps(receipt,indent=2))
if __name__ == '__main__':
    main()
