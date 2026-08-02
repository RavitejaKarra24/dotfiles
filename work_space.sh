#!/usr/bin/env bash

set -Eeuo pipefail

# App name | bundle identifier | AeroSpace workspace
APPS=(
    'WezTerm|com.github.wez.wezterm|1'
    'Zen Browser|app.zen-browser.zen|2'
    'Zed|dev.zed.Zed|3'
    'Music|com.apple.Music|4'
    'Codex|com.openai.codex|8'
    'T3 Code|com.t3tools.t3code|9'
)

WINDOW_TIMEOUT_SECONDS=20

log() {
    printf '[work_space] %s\n' "$*"
}

if [[ "$(uname -s)" != 'Darwin' ]]; then
    log 'This script only supports macOS.' >&2
    exit 1
fi

if ! command -v aerospace >/dev/null 2>&1; then
    log 'AeroSpace is not installed or is not available in PATH.' >&2
    exit 1
fi

if ! aerospace list-workspaces --all >/dev/null 2>&1; then
    log 'AeroSpace is not running.' >&2
    exit 1
fi

# Start every app first so their windows can initialize in parallel.
for app_record in "${APPS[@]}"; do
    IFS='|' read -r app_name bundle_id workspace <<<"$app_record"
    log "Opening $app_name..."
    if ! open -b "$bundle_id"; then
        log "Could not open $app_name ($bundle_id); skipping it." >&2
    fi
done

failures=0

for app_record in "${APPS[@]}"; do
    IFS='|' read -r app_name bundle_id workspace <<<"$app_record"
    deadline=$((SECONDS + WINDOW_TIMEOUT_SECONDS))
    window_ids=''

    while ((SECONDS < deadline)); do
        window_ids="$(
            aerospace list-windows \
                --monitor all \
                --app-bundle-id "$bundle_id" \
                --format '%{window-id}' 2>/dev/null || true
        )"
        [[ -n "$window_ids" ]] && break
        sleep 0.25
    done

    if [[ -z "$window_ids" ]]; then
        log "No $app_name window appeared within ${WINDOW_TIMEOUT_SECONDS}s." >&2
        failures=$((failures + 1))
        continue
    fi

    while IFS= read -r window_id; do
        [[ -n "$window_id" ]] || continue
        if ! aerospace move-node-to-workspace --window-id "$window_id" "$workspace"; then
            log "Could not move $app_name window $window_id to workspace $workspace." >&2
            failures=$((failures + 1))
        fi
    done <<<"$window_ids"

    log "Moved $app_name to workspace $workspace."
done

# Finish on workspace 1, equivalent to pressing Option+1.
aerospace workspace 1

if ((failures > 0)); then
    log "Finished with $failures error(s)." >&2
    exit 1
fi

log 'Workspace setup complete.'
