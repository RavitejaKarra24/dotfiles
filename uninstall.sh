#!/usr/bin/env bash

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DRY_RUN=0
PACKAGES=(
    zsh bash git wezterm vim tmux nvim ghostty karabiner aerospace
    sketchybar lazygit yazi btop fish atuin spotify-player calcure
    zed agents codex pi
)
STOW_ARGS=(
    --no-folding
    '--ignore=(^|/)\.DS_Store$'
    '--ignore=(^|/)node_modules($|/)'
    '--ignore=(^|/)\.env$'
    '--ignore=(^|/)(auth|trust|models-store)\.json$'
    '--ignore=.*\.(log|tmp|bak|swp|swo)$'
)

if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=1
    shift
fi
if (( $# > 0 )); then
    PACKAGES=("$@")
fi

for package in "${PACKAGES[@]}"; do
    [[ -d "$ROOT/$package" ]] || {
        echo "Unknown package: $package" >&2
        exit 2
    }
    args=(--delete --verbose -d "$ROOT" -t "$HOME" "${STOW_ARGS[@]}" "$package")
    if (( DRY_RUN == 1 )); then
        output="$(mktemp "${TMPDIR:-/tmp}/dotfiles-unstow-output.XXXXXX")"
        stow --simulate "${args[@]}" > "$output" 2>&1
        count="$(rg -c '^UNLINK:' "$output" 2>/dev/null || echo 0)"
        printf '%s: %s managed links would be removed\n' "$package" "$count"
        rm -f -- "$output"
    else
        stow "${args[@]}"
    fi
done

if (( DRY_RUN == 1 )); then
    echo "Dry run complete; no links were removed."
else
    echo "Dotfile links removed. Packages and application data were left intact."
fi
