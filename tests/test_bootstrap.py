"""Exercise bootstrap safety and audit failures using disposable fixtures."""

import pathlib
import shlex
import shutil
import subprocess
import tempfile
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]
BASH = "/bin/bash"


class BootstrapTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="dotfiles-test-")
        self.addCleanup(self.temporary.cleanup)
        self.fixture = pathlib.Path(self.temporary.name)
        self.repo = self.fixture / "repo"
        self.home = self.fixture / "home"
        self.repo.mkdir()
        self.home.mkdir()
        (self.repo / "zsh").mkdir()

    def write(self, relative, content):
        path = self.repo / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
        return path

    def run_function(self, script, command):
        source = (ROOT / script).read_text()
        marker = '\nmain "$@"' if script == "install.sh" else '\nrun_check "Bootstrap regression tests"'
        source = source.split(marker, 1)[0]
        setup = f"""
ROOT={shlex.quote(str(self.repo))}
DOTFILES_DIR="$ROOT"
BACKUP_DIR={shlex.quote(str(self.fixture / 'backup'))}
TEST_TARGET={shlex.quote(str(self.home))}
PACKAGES=(zsh bash)
# Guarantee a failing file is checked before a passing file.
find() {{ command find "$@" | sort; }}
"""
        harness = self.fixture / "harness.sh"
        harness.write_text(source + setup + command + "\n")
        return subprocess.run(
            [BASH, "--noprofile", "--norc", str(harness)],
            text=True,
            capture_output=True,
            cwd=self.repo,
            timeout=20,
        )

    def test_syntax_failures_survive_later_successes(self):
        cases = [
            ("check_shell_syntax", "a.sh", "z.sh", "if then\n", "true\n", "bash"),
            ("check_shell_syntax", "zsh/a.zsh", "zsh/z.zsh", "if then\n", "true\n", "zsh"),
            ("check_json", "a.json", "z.json", "{broken\n", "{}\n", "jq"),
            ("check_lua", "a.lua", "z.lua", "local =\n", "return {}\n", "luac"),
        ]
        for function, bad, good, invalid, valid, tool in cases:
            with self.subTest(function=function, file=bad):
                if not shutil.which(tool):
                    self.skipTest(f"{tool} is unavailable")
                bad_path = self.write(bad, invalid)
                good_path = self.write(good, valid)
                self.write("zsh/.zshrc", "true\n")
                failed = self.run_function("doctor.sh", f'run_check "fixture" {function}; exit "$FAILURES"')
                self.assertNotEqual(failed.returncode, 0, failed.stdout + failed.stderr)
                bad_path.write_text(valid)
                passed = self.run_function("doctor.sh", f'run_check "fixture" {function}; exit "$FAILURES"')
                self.assertEqual(passed.returncode, 0, passed.stdout + passed.stderr)
                bad_path.unlink()
                good_path.unlink()

    def test_stow_detects_collisions_between_packages(self):
        if not shutil.which("stow"):
            self.skipTest("Stow is unavailable")
        self.write("zsh/.shared-config", "zsh\n")
        self.write("bash/.shared-config", "bash\n")
        for script, command in [
            ("doctor.sh", 'run_check "fixture" check_stow; exit "$FAILURES"'),
            ("install.sh", "brew() { return 0; }; show_dry_run"),
        ]:
            with self.subTest(script=script):
                result = self.run_function(script, command)
                self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertIn("conflict", result.stderr.lower())
        self.assertEqual(list(self.home.iterdir()), [])

    def test_secret_scan_uses_current_git_visible_files(self):
        self.write(".gitignore", "ignored.txt\n")
        tracked = self.write("tracked.txt", "old\n")
        deleted = self.write("deleted.txt", "deleted\n")
        subprocess.run(["git", "init", "-q", str(self.repo)], check=True, capture_output=True)
        subprocess.run(["git", "-C", str(self.repo), "add", "."], check=True, capture_output=True)
        tracked.write_text("unstaged\n")
        deleted.unlink()
        self.write("untracked.txt", "untracked\n")
        self.write("ignored.txt", "machine-local\n")
        (self.repo / "link.txt").symlink_to(self.repo / "ignored.txt")
        command = r'''
gitleaks() {
    [[ "$1" == detect && "$2" == --no-git && "$3" == --source ]] || return 1
    [[ "$(cat "$4/tracked.txt")" == unstaged ]] || return 1
    [[ -f "$4/untracked.txt" && -f "$4/.gitignore" ]] || return 1
    [[ ! -e "$4/deleted.txt" && ! -e "$4/ignored.txt" && ! -e "$4/link.txt" && ! -d "$4/.git" ]]
}
run_check "fixture" check_secrets
exit "$FAILURES"
'''
        result = self.run_function("doctor.sh", command)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        failed = self.run_function("doctor.sh", 'gitleaks() { return 1; }; run_check "fixture" check_secrets; exit "$FAILURES"')
        self.assertNotEqual(failed.returncode, 0, failed.stdout + failed.stderr)

    @unittest.skipUnless(shutil.which("gitleaks"), "Gitleaks is unavailable")
    def test_secret_allowlist_is_limited_to_one_placeholder_and_path(self):
        example = "agents/.agents/skills/colosseum-copilot/SKILL.md"
        cases = [
            (example, "TOKEN_VALUE", 0),
            ("other.md", "TOKEN_VALUE", 1),
            (example, "synth3tic_validati0n_t0ken_ABCD1234", 1),
        ]
        for relative, token, expected in cases:
            with self.subTest(path=relative, expected=expected):
                path = self.write(relative, 'curl -H "' + "Authorization: Bearer " + token + '" https://example.com\n')
                result = subprocess.run(
                    ["gitleaks", "detect", "--no-git", "--source", str(self.repo),
                     "--config", str(ROOT / ".gitleaks.toml"), "--no-banner", "--redact"],
                    text=True, capture_output=True, timeout=20,
                )
                self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
                path.unlink()

    @unittest.skipUnless(shutil.which("stow"), "Stow is unavailable")
    def test_backup_respects_package_ignores_and_can_be_restored(self):
        self.write("zsh/.zshrc", "managed\n")
        self.write("zsh/README.md", "package documentation\n")
        self.write("zsh/.stow-local-ignore", "^/README.*\n")
        target = self.home / ".zshrc"
        target.write_text("original\n")
        readme = self.home / "README.md"
        readme.write_text("personal notes\n")
        result = self.run_function("install.sh", 'PACKAGES=(zsh); stow_packages "$TEST_TARGET"')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue(target.is_symlink())
        self.assertEqual(target.read_text(), "managed\n")
        self.assertEqual(readme.read_text(), "personal notes\n")
        self.assertFalse(readme.is_symlink())
        self.assertFalse((self.fixture / "backup/README.md").exists())
        self.assertEqual((self.fixture / "backup/.zshrc").read_text(), "original\n")
        target.unlink()
        restored = subprocess.run(
            [BASH, str(ROOT / "restore.sh"), "--manifest", str(self.fixture / "backup/manifest.tsv"), "--apply"],
            text=True, capture_output=True, timeout=10,
        )
        self.assertEqual(restored.returncode, 0, restored.stdout + restored.stderr)
        self.assertEqual(target.read_text(), "original\n")

    @unittest.skipUnless(shutil.which("stow"), "Stow is unavailable")
    def test_backup_refuses_symlinked_parent_without_moving_files(self):
        self.write("zsh/.config/tool/config", "managed\n")
        self.write("zsh/.zshrc", "managed shell\n")
        external = self.fixture / "external"
        (external / "tool").mkdir(parents=True)
        (external / "tool/config").write_text("external config\n")
        (self.home / ".config").symlink_to(external, target_is_directory=True)
        (self.home / ".zshrc").write_text("original shell\n")
        result = self.run_function("install.sh", 'PACKAGES=(zsh); stow_packages "$TEST_TARGET"')
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("symlinked directory", result.stdout)
        self.assertEqual((external / "tool/config").read_text(), "external config\n")
        self.assertEqual((self.home / ".zshrc").read_text(), "original shell\n")
        self.assertFalse((self.fixture / "backup").exists())

    @unittest.skipUnless(shutil.which("stow"), "Stow is unavailable")
    def test_backup_refuses_unrelated_leaf_symlink(self):
        self.write("zsh/.zshrc", "managed\n")
        self.write("zsh/.other", "managed other\n")
        external = self.fixture / "external"
        external.write_text("external\n")
        (self.home / ".zshrc").symlink_to(external)
        (self.home / ".other").write_text("original other\n")
        result = self.run_function("install.sh", 'PACKAGES=(zsh); stow_packages "$TEST_TARGET"')
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(external.read_text(), "external\n")
        self.assertEqual((self.home / ".other").read_text(), "original other\n")
        self.assertFalse((self.fixture / "backup").exists())

    def test_shared_skills_preserve_local_overrides(self):
        shared = self.home / ".agents/skills"
        local = self.home / ".pi/agent/skills"
        local.mkdir(parents=True)
        for name in ("custom", "dangling", "directory", "new"):
            (shared / name).mkdir(parents=True)
        custom = self.fixture / "custom-skill"
        custom.mkdir()
        missing = self.fixture / "missing-skill"
        (local / "custom").symlink_to(custom, target_is_directory=True)
        (local / "dangling").symlink_to(missing, target_is_directory=True)
        (local / "directory").mkdir()
        result = self.run_function("install.sh", 'link_pi_shared_skills "$TEST_TARGET/.agents/skills" "$TEST_TARGET/.pi/agent/skills"')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual((local / "custom").readlink(), custom)
        self.assertEqual((local / "dangling").readlink(), missing)
        self.assertFalse((local / "directory").is_symlink())
        self.assertEqual((local / "new").resolve(), (shared / "new").resolve())


if __name__ == "__main__":
    unittest.main()
