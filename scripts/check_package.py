#!/usr/bin/env python3
"""Compile a fresh consumer of the built archive without optional auth/test tooling."""
import io
import os
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    built = subprocess.run(['mix', 'hex.build'], cwd=ROOT, check=True, text=True, capture_output=True)
    names = re.findall(r'Saved to (\S+\.tar)', built.stdout)
    if len(names) != 1:
        raise RuntimeError('Package build did not identify exactly one fresh archive')
    with tarfile.open(ROOT / names[0]) as outer:
        contents = outer.extractfile('contents.tar.gz').read()
    (ROOT / '.tooling').mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='archive-consumer-', dir=ROOT / '.tooling') as temp:
        work = Path(temp)
        package = work / 'package'
        with tarfile.open(fileobj=io.BytesIO(contents), mode='r:gz') as archive:
            for member in archive.getmembers():
                path = PurePosixPath(member.name)
                if path.is_absolute() or '..' in path.parts or member.issym() or member.islnk():
                    raise RuntimeError('Unsafe package member')
                if path.parts[0] in {'dev', 'test', 'scripts', '.upstream', '.tooling', 'reports'}:
                    raise RuntimeError('Repository-only tooling leaked into package')
                if member.isfile():
                    target = package / Path(*path.parts)
                    target.parent.mkdir(parents=True, exist_ok=True)
                    target.write_bytes(archive.extractfile(member).read())
        consumer = work / 'consumer'
        consumer.mkdir()
        (consumer / 'mix.exs').write_text('''defmodule Consumer.MixProject do
  use Mix.Project
  def project, do: [app: :consumer, version: "0.1.0", elixir: "~> 1.17", deps: [{:arbor_a2a, path: "../package"}]]
  def application, do: []
end
''')
        (consumer / 'verify.exs').write_text('''{:ok, client} = Arbor.A2A.Client.new("https://agent.example/a2a")
true = client.url == "https://agent.example/a2a"
"1.0" = Arbor.A2A.protocol_version()
%{"jsonrpc" => "2.0"} = Arbor.RPC.JSONRPC.request("ListTasks", %{}, 1)
false = Code.ensure_loaded?(Oidcc)
false = Code.ensure_loaded?(Bandit)
false = Code.ensure_loaded?(StreamData)
IO.puts("ARCHIVE_CONSUMER_OK")
''')
        env = {k: v for k, v in os.environ.items() if k not in {'MIX_BUILD_PATH', 'MIX_DEPS_PATH', 'MIX_ENV'}}
        env['MIX_ENV'] = 'prod'
        for command in [['mix', 'deps.get'], ['mix', 'run', 'verify.exs']]:
            result = subprocess.run(command, cwd=consumer, env=env, check=True, text=True, capture_output=True, timeout=180)
        if 'ARCHIVE_CONSUMER_OK' not in result.stdout:
            raise RuntimeError('Consumer assertions did not complete')
    print('Fresh archive consumer passes; optional OIDCC and repository test tooling are absent')


if __name__ == '__main__':
    main()
