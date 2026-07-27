#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
QUICK=0
CI_MODE=0
FAILURES=0

for arg in "$@"; do
    case "$arg" in
    --quick) QUICK=1 ;;
    --ci) CI_MODE=1 ;;
    -h | --help)
        echo "Usage: $0 [--quick] [--ci]"
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
    local file
    while IFS= read -r file; do
        bash -n "$file"
    done < <(find "$ROOT" -type f -name '*.sh' \
        ! -path '*/node_modules/*' \
        ! -path '*/.git/*' \
        ! -path '*/skills/*' -print)

    while IFS= read -r file; do
        zsh -n "$file"
    done < <(find "$ROOT/zsh" -type f \( -name '*.zsh' -o -name '.zshrc' -o -name '.zshenv' -o -name '.zprofile' \) -print)
}

check_json() {
    local file
    while IFS= read -r file; do
        jq empty "$file"
    done < <(find "$ROOT" -type f -name '*.json' \
        ! -path '*/node_modules/*' \
        ! -path '*/skills/*' \
        ! -path '*/zed/*' -print)
}

check_toml() {
    python3 - "$ROOT" <<'PY'
import pathlib
import sys
import tomllib

root = pathlib.Path(sys.argv[1])
excluded = {"node_modules", ".git", "skills"}
for path in root.rglob("*.toml"):
    if excluded.intersection(path.parts):
        continue
    with path.open("rb") as handle:
        tomllib.load(handle)
PY
}

check_lua() {
    local file
    while IFS= read -r file; do
        luac -p "$file"
    done < <(find "$ROOT" -type f -name '*.lua' \
        ! -path '*/node_modules/*' \
        ! -path '*/skills/*' -print)
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

    for package in zsh bash git wezterm vim tmux nvim ghostty karabiner aerospace sketchybar lazygit yazi btop fish atuin spotify-player calcure zed agents codex pi; do
        [[ -d "$ROOT/$package" ]] || continue
        stow --simulate --verbose -d "$ROOT" -t "$target" "${stow_args[@]}" "$package" >>"$output" 2>&1 || result=1
    done

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
    env YAZI_CONFIG_HOME="$ROOT/yazi/.config/yazi" yazi --debug >/dev/null
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

if command -v shellcheck >/dev/null 2>&1; then
    run_check "ShellCheck bootstrap scripts" shellcheck "$ROOT/install.sh" "$ROOT/update.sh" "$ROOT/doctor.sh"
else
    warn "ShellCheck is unavailable"
fi

if command -v shfmt >/dev/null 2>&1; then
    run_check "Shell formatting" shfmt -d -i 4 "$ROOT/install.sh" "$ROOT/update.sh" "$ROOT/doctor.sh"
else
    warn "shfmt is unavailable"
fi

if command -v gitleaks >/dev/null 2>&1; then
    run_check "Gitleaks worktree scan" gitleaks detect --source "$ROOT" --no-banner --redact
else
    warn "Gitleaks is unavailable"
fi

if ((CI_MODE == 0)) && command -v brew >/dev/null 2>&1; then
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
