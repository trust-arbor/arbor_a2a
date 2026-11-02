#!/usr/bin/env python3
"""Execute the documented example client against the actual example server."""
import json
from qualify import REPORTS, run, service

REPORTS.mkdir(exist_ok=True)
with service(['mix', 'run', 'examples/echo_server.exs'], 'example-server.log') as base:
    result = run(['mix', 'run', 'examples/client.exs', base], capture_output=True, timeout=30)
    (REPORTS / 'example-client.log').write_text(result.stdout + result.stderr)
    task = json.loads(result.stdout[result.stdout.index('{'):])
    if task['status']['state'] != 'TASK_STATE_COMPLETED' or task['history'][-1]['parts'] != [{'text': 'Echo: Hello, A2A'}]:
        raise RuntimeError('Example did not return the expected completed task')
print('Documented example client/server pass over real HTTP')
