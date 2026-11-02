#!/usr/bin/env python3
"""Regenerate canonical wire types; no edits to upstream proto are performed.

Requires protoc, protoc-gen-elixir 0.17.1 and the hash-locked TCK Python Google
API includes. Generated messages retain upstream full protobuf names; only the
Elixir namespace is prefixed. The pinned proto/Apache-2.0 license stays bundled.
"""
from pathlib import Path
import shutil
import subprocess
import tempfile
ROOT = Path(__file__).resolve().parents[1]

def main():
    plugin = shutil.which('protoc-gen-elixir') or str(Path.home() / '.mix/escripts/protoc-gen-elixir')
    includes = ROOT / '.venv/lib/python3.13/site-packages'
    with tempfile.TemporaryDirectory() as directory:
        subprocess.run(['protoc', '-Itest/fixtures/spec', '-I' + str(includes), '--plugin=protoc-gen-elixir=' + plugin,
            '--elixir_out=package_prefix=Arbor.A2A.Proto,gen_descriptors=true,plugins=grpc:' + directory, 'a2a.proto'], cwd=ROOT, check=True)
        files = list(Path(directory).rglob('a2a.pb.ex'))
        if len(files) != 1 or 'protoc_gen_elixir_version: "0.17.1"' not in files[0].read_text():
            raise RuntimeError('Unexpected generator version or output')
        header = '# Generated from A2A v1.0.1 (3303592588e388e62e0f69f701af531d2f4e3991).\n# Upstream protocol: Apache-2.0; see priv/licenses/a2a-Apache-2.0.txt.\n# Regenerate with scripts/generate_proto.py; do not edit by hand.\n'
        target = ROOT / 'lib/arbor_a2a/proto/a2a.pb.ex'
        target.write_text(header + files[0].read_text())
        subprocess.run(['mix', 'format', str(target)], cwd=ROOT, check=True)
if __name__ == '__main__':
    main()
