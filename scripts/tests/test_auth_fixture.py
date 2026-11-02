import contextlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import Mock, patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import qualify_auth as auth


class KeycloakReadinessTest(unittest.TestCase):
    def test_exited_container_fails_without_waiting_for_deadline(self):
        state = {'Running': False, 'ExitCode': 1, 'OOMKilled': False}
        with patch.object(auth.urllib.request, 'urlopen', side_effect=OSError('refused')), \
                patch.object(auth, 'run', return_value=subprocess.CompletedProcess([], 0, json.dumps(state))), \
                patch.object(auth.time, 'sleep') as sleep:
            with self.assertRaisesRegex(RuntimeError, 'exited before readiness.*exit=1.*auth-keycloak.log'):
                auth.wait_for_keycloak('owned-fixture', 'http://127.0.0.1:1234')
            sleep.assert_not_called()

    def test_live_container_can_become_ready(self):
        response = Mock(status=200)
        state = {'Running': True}
        with patch.object(auth.urllib.request, 'urlopen', side_effect=[OSError('starting'), contextlib.nullcontext(response)]) as get, \
                patch.object(auth, 'run', return_value=subprocess.CompletedProcess([], 0, json.dumps(state))), \
                patch.object(auth.time, 'sleep') as sleep:
            auth.wait_for_keycloak('owned-fixture', 'http://127.0.0.1:1234')
            self.assertEqual(get.call_count, 2)
            sleep.assert_called_once()

    def test_unready_live_container_still_has_a_deadline(self):
        with patch.object(auth.urllib.request, 'urlopen', side_effect=OSError('refused')), \
                patch.object(auth, 'run', return_value=subprocess.CompletedProcess([], 0, '{"Running": true}')), \
                patch.object(auth.time, 'monotonic', side_effect=[0, 2]), \
                patch.object(auth.time, 'sleep') as sleep:
            with self.assertRaisesRegex(RuntimeError, 'readiness deadline exceeded.*auth-keycloak.log'):
                auth.wait_for_keycloak('owned-fixture', 'http://127.0.0.1:1234', timeout=1)
            sleep.assert_not_called()


class KeycloakCleanupTest(unittest.TestCase):
    def test_failed_start_preserves_logs_before_removing_owned_container(self):
        def start(args, **_opts):
            if args[:2] == ['docker', 'port']:
                return subprocess.CompletedProcess(args, 0, '127.0.0.1:1234\n')
            return subprocess.CompletedProcess(args, 0, 'fixture-id\n')

        def docker(args, **_opts):
            if args[:2] == ['docker', 'logs']:
                return subprocess.CompletedProcess(args, 0, 'fixture log\n', 'import failed\n')
            self.assertTrue((reports / 'auth-keycloak.log').exists())
            return subprocess.CompletedProcess(args, 0, '', '')

        with tempfile.TemporaryDirectory() as directory:
            reports = Path(directory)
            with patch.object(auth, 'REPORTS', reports), \
                    patch.object(auth, 'run', side_effect=start) as start_command, \
                    patch.object(auth, 'wait_for_keycloak', side_effect=RuntimeError('startup failed')), \
                    patch.object(auth.subprocess, 'run', side_effect=docker) as cleanup:
                with self.assertRaisesRegex(RuntimeError, 'startup failed'):
                    with auth.keycloak():
                        self.fail('Failed startup must not yield an issuer')
                self.assertEqual((reports / 'auth-keycloak.log').read_text(), 'fixture log\nimport failed\n')
                name = start_command.call_args_list[0].args[0][4]
                self.assertNotIn('--rm', start_command.call_args_list[0].args[0])
                self.assertEqual(cleanup.call_args_list[-1].args[0], ['docker', 'rm', '--force', name])


if __name__ == '__main__':
    unittest.main()
