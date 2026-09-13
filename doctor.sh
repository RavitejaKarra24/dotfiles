#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
QUICK=0
FAILURES=0

for arg in "$@"; do
    case "$arg" in
    --quick) QUICK=1 ;;
    -h | --help)
        echo "Usage: $0 [--quick]"
        exit 0
        ;;
    *)
        echo "Unknown argument: $arg" >&2
        exit 2
        ;;
    esac
done

pass() { printf '\033[0;32m[PASS]\033[0m %s\n' "$1"; }
warn() { printf '\033[0;33m[WARN]\033[0m %s\n' "$1"; }
fail() {
    printf '\033[0;31m[FAIL]\033[0m %s\n' "$1"
    FAILURES=$((FAILURES + 1))
}

run_check() {
    local label="$1"
    shift
    if "$@"; then
        pass "$label"
    else
        fail "$label"
    fi
}

check_shell_syntax() {
    local file result=0
    while IFS= read -r file; do
        bash -n "$file" || result=1
    done < <(find "$ROOT" \( -name node_modules -o -name .git -o -name skills \) -prune \
        -o -type f \( -name '*.sh' -o -name .bashrc -o -name sketchybarrc \) -print)

    while IFS= read -r file; do
        zsh -n "$file" || result=1
    done < <(find "$ROOT/zsh" -type f \( -name '*.zsh' -o -name '.zshrc' -o -name '.zshenv' -o -name '.zprofile' \) -print)
    return "$result"
}

check_json() {
    local file result=0
    while IFS= read -r file; do
        jq empty "$file" || result=1
    done < <(find "$ROOT" \( -name node_modules -o -name .git -o -name skills -o -name zed \) -prune \
        -o -type f -name '*.json' -print)
    return "$result"
}

check_toml() {
    python3 - "$ROOT" <<'PY'
import os
import pathlib
import sys
import tomllib

root = pathlib.Path(sys.argv[1])
excluded = {"node_modules", ".git", "skills"}
for directory, children, files in os.walk(root):
    children[:] = [name for name in children if name not in excluded]
    for name in files:
        if name.endswith(".toml"):
            with (pathlib.Path(directory) / name).open("rb") as handle:
                tomllib.load(handle)
PY
}

check_lua() {
    local file result=0
    while IFS= read -r file; do
        luac -p "$file" || result=1
    done < <(find "$ROOT" \( -name node_modules -o -name .git -o -name skills \) -prune \
        -o -type f -name '*.lua' -print)
    return "$result"
}

check_stow() {
    local target output package result=0
    local stow_args=(
        --no-folding
        '--ignore=(^|/)\.DS_Store$'
        '--ignore=(^|/)node_modules($|/)'
        '--ignore=(^|/)\.env$'
        '--ignore=(^|/)(auth|trust|models-store)\.json$'
        '--ignore=.*\.(log|tmp|bak|swp|swo)$'
    )
    target="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-doctor-stow.XXXXXX")"
    output="$(mktemp "${TMPDIR:-/tmp}/dotfiles-doctor-stow-output.XXXXXX")"

    local packages=()
    for package in zsh bash git wezterm vim tmux nvim ghostty karabiner aerospace sketchybar lazygit yazi btop fish atuin spotify-player calcure zed agents codex pi neru; do
        [[ -d "$ROOT/$package" ]] || continue
        packages+=("$package")
    done
    stow --simulate --verbose -d "$ROOT" -t "$target" "${stow_args[@]}" "${packages[@]}" >"$output" 2>&1 || result=1
    if ((result != 0)); then
        cat "$output" >&2
    fi

    local forbidden='node_modules|\.pi/agent/(sessions|workflows|bin)(/| )|\.pi/agent/(auth|trust|models-store)\.json|\.pi/agent/\.env( |$)'
    if rg -q "$forbidden" "$output"; then
        echo "Stow plan contains a dependency, runtime, or secret path:" >&2
        rg "$forbidden" "$output" | head -20 >&2
        result=1
    fi
    rm -rf -- "$target"
    rm -f -- "$output"
    return "$result"
}

check_yazi() {
    if command -v ya >/dev/null 2>&1 && ya env --help >/dev/null 2>&1; then
        env YAZI_CONFIG_HOME="$ROOT/yazi/.config/yazi" ya env >/dev/null
    else
        env YAZI_CONFIG_HOME="$ROOT/yazi/.config/yazi" yazi --debug >/dev/null
    fi
}

check_nvim() {
    local data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
    local state_home cache_home
    state_home="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-doctor-nvim-state.XXXXXX")"
    cache_home="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-doctor-nvim-cache.XXXXXX")"
    local result=0
    env \
        DOTFILES_DOCTOR=1 \
        XDG_CONFIG_HOME="$ROOT/nvim/.config" \
        XDG_DATA_HOME="$data_home" \
        XDG_STATE_HOME="$state_home" \
        XDG_CACHE_HOME="$cache_home" \
        nvim --headless '+qa' >/dev/null 2>&1 || result=1
    rm -rf -- "$state_home" "$cache_home"
    return "$result"
}

check_secrets() {
    local scan_dir result=0
    scan_dir="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-doctor-secrets.XXXXXX")" || return 1
    # Scan current tracked and unignored files, including unstaged edits.
    # Keep Git history, dependencies, and machine-local auth out of this scan.
    python3 - "$ROOT" "$scan_dir" <<'PY' || result=1
import os
import pathlib
import shutil
import subprocess
import sys

root, destination = map(pathlib.Path, sys.argv[1:])
files = subprocess.check_output([
    "git", "-C", str(root), "ls-files", "--cached", "--others", "--exclude-standard", "-z",
])
for name in set(files.split(b"\0")) - {b""}:
    relative = pathlib.Path(os.fsdecode(name))
    source = root / relative
    if source.is_symlink() or not source.is_file():
        continue
    target = destination / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, target)
PY
    if ((result == 0)); then
        gitleaks detect --no-git --source "$scan_dir" --no-banner --redact || result=1
    fi
    rm -rf -- "$scan_dir"
    return "$result"
}

run_check "Bootstrap regression tests" python3 "$ROOT/tests/test_bootstrap.py"
run_check "Bash and Zsh syntax" check_shell_syntax
run_check "JSON files" check_json
run_check "TOML files" check_toml
run_check "Lua files" check_lua
run_check "Stow simulation excludes runtime trees" check_stow

if command -v yazi >/dev/null 2>&1; then
    run_check "Yazi application config" check_yazi
else
    warn "Yazi is unavailable; skipped application-aware config check"
fi

if command -v nvim >/dev/null 2>&1 && [[ -d "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/lazy.nvim" ]]; then
    run_check "Neovim headless startup" check_nvim
else
    warn "Neovim or its installed lazy.nvim cache is unavailable; Lua parsing still ran"
fi

BOOTSTRAP_SCRIPTS=(
    "$ROOT/install.sh"
    "$ROOT/update.sh"
    "$ROOT/doctor.sh"
    "$ROOT/restore.sh"
    "$ROOT/uninstall.sh"
)

if command -v shellcheck >/dev/null 2>&1; then
    run_check "ShellCheck bootstrap scripts" shellcheck "${BOOTSTRAP_SCRIPTS[@]}"
else
    warn "ShellCheck is unavailable"
fi

if command -v shfmt >/dev/null 2>&1; then
    run_check "Shell formatting" shfmt -d -i 4 "${BOOTSTRAP_SCRIPTS[@]}"
else
    warn "shfmt is unavailable"
fi

if command -v gitleaks >/dev/null 2>&1; then
    run_check "Gitleaks worktree scan" check_secrets
else
    warn "Gitleaks is unavailable"
fi

if command -v brew >/dev/null 2>&1; then
    run_check "Brewfile satisfaction" brew bundle check --file="$ROOT/Brewfile"
fi

if ((QUICK == 0)); then
    run_check "Pi typecheck" npm --prefix "$ROOT/pi/.pi/agent" run check
    run_check "Pi formatting" npm --prefix "$ROOT/pi/.pi/agent" run format:check
    run_check "Pi deterministic tests" npm --prefix "$ROOT/pi/.pi/agent" run test:unit
fi

if ((FAILURES > 0)); then
    printf '\n%d check(s) failed.\n' "$FAILURES" >&2
    exit 1
fi

printf '\nAll selected dotfiles checks passed.\n'
