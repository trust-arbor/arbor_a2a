#!/usr/bin/env python3
"""Verify pinned source snapshots; optionally detect upstream drift without adopting it."""
import argparse
import hashlib
import json
from pathlib import Path
import urllib.request

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--upstream', action='store_true')
    args = parser.parse_args()
    manifest = json.loads((ROOT / 'test/conformance/upstream.json').read_text())
    hashes = json.loads((ROOT / 'test/fixtures/spec/SHA256.json').read_text())
    for filename, digest in hashes.items():
        actual = hashlib.sha256((ROOT / 'test/fixtures/spec' / filename).read_bytes()).hexdigest()
        if actual != digest:
            raise SystemExit(f'Spec snapshot changed without review: {filename}')
    if args.upstream:
        checks = [
            ('spec release', 'https://api.github.com/repos/a2aproject/A2A/releases/latest', 'tag_name', manifest['spec']['tag']),
            ('spec main', 'https://api.github.com/repos/a2aproject/A2A/commits/main', 'sha', manifest['spec']['tracked_main_revision']),
            ('TCK', 'https://api.github.com/repos/a2aproject/a2a-tck/commits/main', 'sha', manifest['tck']['revision']),
            ('SDK', 'https://registry.npmjs.org/@a2a-js/sdk/latest', 'version', manifest['sdk']['version'])]
        changed = []
        for name, url, field, expected in checks:
            with urllib.request.urlopen(url, timeout=20) as response:
                actual = json.load(response)[field]
            if actual != expected:
                changed.append(f'{name}: reviewed {expected}, upstream {actual}')
        if changed:
            raise SystemExit('Upstream review required:\n' + '\n'.join(changed))
    print('Pinned specification snapshots verified' + ('; upstream baselines unchanged' if args.upstream else ''))


if __name__ == '__main__':
    main()
