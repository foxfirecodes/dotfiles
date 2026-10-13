"""Exercise recovery without SSH or a real GPG agent."""
import pathlib
import subprocess
import tempfile
import unittest

SCRIPT = pathlib.Path(__file__).resolve().parents[1] / '.bin/gpg-ssh'
HELPER = SCRIPT.read_text().split("<<'REMOTE'\n", 1)[1].split('\nREMOTE\n', 1)[0]


class RecoveryTests(unittest.TestCase):
    def test_stale_cleanup_journals(self):
        for pid in (None, '999999999', str(__import__('os').getpid())):
            with self.subTest(pid=pid), tempfile.TemporaryDirectory() as root:
                state = pathlib.Path(root) / 'agent.gpg-ssh'
                (state / 'cleaning').mkdir(parents=True)
                (state / 'owner').write_text('gpg-ssh.test\n')
                if pid is not None:
                    (state / 'cleaning/pid').write_text(pid + '\n')
                config = pathlib.Path(root) / 'config'
                config.write_text('[commit]\n\tgpgsign = true\n')
                repo = state / 'repo.0'
                repo.mkdir()
                (repo / 'changed').touch()
                (repo / 'config').write_bytes(str(config).encode() + b'\0')
                (repo / 'values').write_bytes(b'false\0false\0')
                result = subprocess.run(['bash', '-c', HELPER, '--', 'recover', str(state)],
                                        capture_output=True, text=True, timeout=20)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertFalse(state.exists())
                values = subprocess.check_output(['git', 'config', '--file', str(config),
                                                  '--get-all', 'commit.gpgsign'], text=True)
                self.assertEqual(values, 'false\nfalse\n')

    def test_live_kernel_lock_is_respected(self):
        import fcntl
        with tempfile.TemporaryDirectory() as root:
            state = pathlib.Path(root) / 'agent.gpg-ssh'
            state.mkdir()
            (state / 'owner').write_text('gpg-ssh.test\n')
            with (state / 'cleanup.lock').open('w') as lock:
                fcntl.flock(lock, fcntl.LOCK_EX)
                result = subprocess.run(['bash', '-c', HELPER, '--', 'recover', str(state)],
                                        capture_output=True, text=True, timeout=20)
                self.assertEqual(result.returncode, 1)
                self.assertIn('another cleanup is still running', result.stderr)
                self.assertTrue(state.exists())
            result = subprocess.run(['bash', '-c', HELPER, '--', 'recover', str(state)],
                                    capture_output=True, text=True, timeout=20)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertFalse(state.exists())


if __name__ == '__main__':
    unittest.main()
