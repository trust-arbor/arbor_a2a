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
with service(['mix', 'run', 'examples/managed_server.exs'], 'example-managed-server.log') as base:
    result = run(['mix', 'run', 'examples/stream_client.exs', base + '/a2a'], capture_output=True, timeout=30)
    (REPORTS / 'example-stream-client.log').write_text(result.stdout + result.stderr)
    events = [json.loads(line) for line in result.stdout.splitlines() if line.startswith('{')]
    if not events or 'task' not in events[0] or events[-1].get('statusUpdate', {}).get('status', {}).get('state') != 'TASK_STATE_COMPLETED':
        raise RuntimeError('Managed streaming example did not produce an ordered completed task')
print('Documented echo and managed streaming examples pass over real HTTP')
