#!/usr/bin/env python3
"""Integration tests using disposable SSH keys and local push destinations."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SIGNY = Path(__file__).resolve().parents[1] / ".bin" / "signy"


class SignyTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.keys = tempfile.TemporaryDirectory(prefix="signy-keys-")
        cls.signing_key = Path(cls.keys.name) / "key"
        subprocess.run(
            ["ssh-keygen", "-q", "-t", "ed25519", "-N", "", "-f", str(cls.signing_key)],
            check=True,
        )
        cls.allowed_signers = Path(cls.keys.name) / "allowed_signers"
        cls.allowed_signers.write_text(
            "signy@example.test " + cls.signing_key.with_suffix(".pub").read_text()
        )

    @classmethod
    def tearDownClass(cls):
        cls.keys.cleanup()

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="signy-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / "working"
        self.remote = self.root / "remote.git"
        self.env = dict(
            os.environ,
            GIT_CONFIG_GLOBAL=os.devnull,
            GIT_CONFIG_SYSTEM=os.devnull,
            GIT_CONFIG_NOSYSTEM="1",
            GIT_TERMINAL_PROMPT="0",
        )
        self.run_command("git", "init", "-q", "-b", "main", str(self.repo), cwd=self.root)
        self.run_command("git", "init", "-q", "--bare", str(self.remote), cwd=self.root)
        for key, value in {
            "user.name": "Signy Test",
            "user.email": "signy@example.test",
            "gpg.format": "ssh",
            "user.signingKey": str(self.signing_key),
            "gpg.ssh.allowedSignersFile": str(self.allowed_signers),
            "commit.gpgSign": "true",
        }.items():
            self.git("config", key, value)
        self.counter = 0
        self.base = self.commit()
        self.git("remote", "add", "origin", str(self.remote))
        self.git("push", "-q", "origin", "main")

    def run_command(self, *args, cwd=None, succeeds=True):
        result = subprocess.run(
            args, cwd=cwd or self.repo, env=self.env, text=True, capture_output=True
        )
        if succeeds:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def git(self, *args, **kwargs):
        return self.run_command("git", *args, **kwargs).stdout.strip()

    def signy(self, *args, **kwargs):
        return self.run_command(str(SIGNY), *args, **kwargs)

    def commit(self, signed=False, message=None, cwd=None):
        self.counter += 1
        (cwd or self.repo).joinpath("work.txt").write_text(f"{self.counter}\n")
        self.git("add", "work.txt", cwd=cwd)
        self.git(
            "commit", "-q", "-S" if signed else "--no-gpg-sign",
            "-m", message or f"commit {self.counter}", cwd=cwd,
        )
        return self.git("rev-parse", "HEAD", cwd=cwd)

    def assert_push_blocked(self, *refspecs, destination="origin", cwd=None):
        result = self.run_command(
            "git", "push", "-q", destination, *refspecs, cwd=cwd, succeeds=False
        )
        self.assertIn("push blocked: unsigned commit", result.stderr)

    def test_apply_advances_base_and_signs_only_new_commits(self):
        self.signy("init")
        hook = self.repo / ".git/hooks/pre-push"
        self.assertTrue(os.access(hook, os.X_OK))
        self.assertEqual(self.git("config", "commit.gpgSign"), "false")
        self.commit()
        unsigned_head = self.commit(signed=True)
        self.assert_push_blocked("main")  # A signed tip cannot hide unsigned ancestors.
        self.signy("apply")
        signed_head = self.git("rev-parse", "HEAD")
        self.assertNotEqual(signed_head, unsigned_head)
        self.assertEqual(self.git("config", "branch.main.signyBase"), signed_head)
        for commit in self.git("rev-list", f"{self.base}..HEAD").splitlines():
            self.git("verify-commit", commit)
        self.signy("apply")
        self.assertEqual(self.git("rev-parse", "HEAD"), signed_head)

        self.commit()
        self.signy("apply")
        self.assertEqual(self.git("rev-parse", "HEAD^"), signed_head)
        self.assertEqual(
            self.git("config", "branch.main.signyBase"), self.git("rev-parse", "HEAD")
        )
        self.git("push", "-q", "origin", "main")

        hook.unlink()
        self.signy("apply")  # Install the hook for previously initialized branches too.
        self.assertTrue(os.access(hook, os.X_OK))

    def test_failed_signing_preserves_base(self):
        self.signy("init")
        unsigned_head = self.commit()
        self.git("config", "user.signingKey", str(self.root / "missing-key"))
        self.signy("apply", succeeds=False)
        self.assertEqual(self.git("config", "branch.main.signyBase"), self.base)
        self.git("rebase", "--abort")
        self.assertEqual(self.git("rev-parse", "HEAD"), unsigned_head)

    def test_new_branches_tags_urls_and_deletions(self):
        self.signy("init")
        self.commit(message="message\n\ngpgsig fake-signature-in-the-message")
        self.assert_push_blocked("HEAD:refs/heads/feature")
        self.git("tag", "unsigned-target")
        self.assert_push_blocked("refs/tags/unsigned-target")
        self.git("tag", "old-history", self.base)
        self.git("push", "-q", "origin", "refs/tags/old-history")

        self.signy("apply")
        self.git("push", "-q", "origin", "HEAD:refs/heads/feature")
        self.git("tag", "-a", "signed-target", "-m", "tag")
        self.git("push", "-q", "origin", "refs/tags/signed-target")
        self.git("push", "-q", str(self.remote), "main")
        self.git("push", "-q", "origin", ":refs/heads/feature")
        self.commit()
        self.assert_push_blocked("main", destination=str(self.remote))

    def test_force_push_checks_replacement_history(self):
        self.signy("init")
        self.commit(signed=True)
        self.git("push", "-q", "origin", "main")
        self.git("reset", "--hard", self.base)
        self.commit()
        self.assert_push_blocked("+main")
        self.git("commit", "-q", "--amend", "--no-edit", "-S")
        self.git("push", "-q", "origin", "+main")

    def test_multiple_refs_and_stale_tracking_refs_cannot_hide_unsigned_commits(self):
        self.signy("init")
        self.commit(signed=True)
        self.git("branch", "signed-branch")
        unsigned_head = self.commit()
        self.git("update-ref", "refs/remotes/origin/stale", unsigned_head)
        self.assert_push_blocked("signed-branch", "main")
        self.assertEqual(self.git("ls-remote", "origin", "refs/heads/main").split()[0], self.base)
        self.assertEqual(self.git("ls-remote", "origin", "refs/heads/signed-branch"), "")
        self.assert_push_blocked("HEAD:refs/heads/new-branch")

    def test_other_remotes_do_not_exempt_unsigned_history(self):
        self.signy("init")
        self.commit(signed=True)
        other_remote = self.root / "other.git"
        self.run_command("git", "init", "-q", "--bare", str(other_remote))
        self.git("remote", "add", "other", str(other_remote))
        self.assert_push_blocked("main", destination="other")
        self.git("push", "-q", "origin", "main")

    def test_existing_hooks_are_preserved(self):
        hook = self.repo / ".git/hooks/pre-push"
        contents = "#!/bin/sh\nexit 0\n"
        hook.write_text(contents)
        self.signy("init", succeeds=False)
        self.assertEqual(hook.read_text(), contents)
        self.assertEqual(self.git("config", "commit.gpgSign"), "true")
        self.git("config", "--get", "branch.main.signyBase", succeeds=False)

    def test_custom_hook_path_from_subdirectory_and_repeated_init(self):
        self.git("config", "core.hooksPath", ".git/custom-hooks")
        subdirectory = self.repo / "subdirectory"
        subdirectory.mkdir()
        self.signy("init", cwd=subdirectory)
        hook = self.repo / ".git/custom-hooks/pre-push"
        self.assertTrue(os.access(hook, os.X_OK))
        self.signy("init", cwd=subdirectory)
        self.commit()
        self.assert_push_blocked("main", cwd=subdirectory)

    def test_linked_worktree(self):
        worktree = self.root / "linked"
        self.git("worktree", "add", "-q", "-b", "linked", str(worktree))
        self.signy("init", cwd=worktree)
        self.commit(cwd=worktree)
        self.assert_push_blocked("linked", cwd=worktree)
        self.signy("apply", cwd=worktree)
        self.assertEqual(
            self.git("config", "branch.linked.signyBase"),
            self.git("rev-parse", "HEAD", cwd=worktree),
        )
        self.assertEqual(self.git("rev-parse", "HEAD"), self.base)
        self.git("push", "-q", "origin", "linked", cwd=worktree)


if __name__ == "__main__":
    unittest.main(verbosity=2)
