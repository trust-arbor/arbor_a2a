#!/usr/bin/env python3
"""Enforce the narrow, documented optional-gRPC dependency mitigation."""
from pathlib import Path
import re
import subprocess
ROOT = Path(__file__).resolve().parents[1]
lock = (ROOT / 'mix.lock').read_text()
match = re.search(r'"cowboy": \{:hex, :cowboy, "([^"]+)"', lock)
if not match or tuple(map(int, match[1].split('.'))) < (2, 16, 0):
    raise SystemExit('Cowboy >= 2.16 is required for the response-header mitigation')
# The vendor default must remain error_terminate. Untrusted structured-field
# strings are never built by ArborA2A; host listeners must retain this default.
source = ROOT / 'deps/cowboy/src/cowboy_http.erl'
if not source.exists() or not re.search(r'maps:get\(invalid_response_headers,\s*[^,]+,\s*error_terminate\)', source.read_text()):
    raise SystemExit('Cowboy response-header guard could not be verified')
subprocess.run(['mix', 'hex.audit'], cwd=ROOT, check=True)
print('Optional gRPC dependency policy verified; exact acknowledged advisory remains visible above')
