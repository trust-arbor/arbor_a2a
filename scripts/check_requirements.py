#!/usr/bin/env python3
"""Inventory every normative prose block without claiming per-clause certification."""
import argparse
import hashlib
import json
from pathlib import Path
import re
ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / 'test/conformance/requirements.json'
SOURCE = ROOT / 'test/fixtures/spec/specification.md'

def inventory():
    content = SOURCE.read_text()
    section = 'Preamble'
    block = []
    start = 1
    entries = []
    used = {}
    def flush():
        text = '\n'.join(block)
        levels = sorted(set(re.findall(r'\b(MUST|SHOULD|MAY|REQUIRED|RECOMMENDED)\b', text)))
        if levels:
            digest = hashlib.sha256((section + '\n' + text).encode()).hexdigest()[:16]
            used[digest] = used.get(digest, 0) + 1
            ident = digest if used[digest] == 1 else digest + '-' + str(used[digest])
            entries.append({'id': ident, 'line': start, 'section': section, 'levels': levels,
                'text': text, 'evidence_scope': 'docs/REQUIREMENTS.md', 'individual_qualification': False})
    for line_number, line in enumerate(content.splitlines(), 1):
        if line.startswith('#'):
            flush(); block = []; section = line.lstrip('# ').strip(); start = line_number + 1
        elif not line.strip():
            flush(); block = []; start = line_number + 1
        else:
            block.append(line)
    flush()
    return {'spec': 'v1.0.1', 'source_sha256': hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
        'description': 'Normative prose inventory; references are scope pointers, not per-clause pass claims.', 'blocks': entries}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    value = inventory()
    if args.write:
        TARGET.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n')
    elif not TARGET.exists() or json.loads(TARGET.read_text()) != value:
        raise SystemExit('Normative requirements inventory changed; review before regenerating')
    print(f"Normative inventory verified: {len(value['blocks'])} blocks, complete for pinned source")
if __name__ == '__main__':
    main()
