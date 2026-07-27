#!/usr/bin/env bash

set -Eeuo pipefail

APPLY=0
MANIFEST=""

while (( $# > 0 )); do
    case "$1" in
        --apply) APPLY=1 ;;
        --manifest)
            shift
            MANIFEST="${1:-}"
            ;;
        -h|--help)
            echo "Usage: $0 [--manifest PATH] [--apply]"
            echo "Without --apply, prints and verifies the restore plan."
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            exit 2
            ;;
    esac
    shift
done

if [[ -z "$MANIFEST" ]]; then
    MANIFEST="$(find "$HOME/.dotfiles-backup" -name manifest.tsv -type f 2>/dev/null | sort | tail -1)"
fi
[[ -f "$MANIFEST" ]] || {
    echo "No backup manifest found. Pass --manifest PATH." >&2
    exit 1
}

echo "Manifest: $MANIFEST"
while IFS=$'\t' read -r target backup type checksum; do
    [[ "$target" == "target" ]] && continue
    [[ -e "$backup" || -L "$backup" ]] || {
        echo "Missing backup: $backup" >&2
        exit 1
    }
    if [[ "$checksum" != "-" && -f "$backup" ]]; then
        actual="$(shasum -a 256 "$backup" | awk '{print $1}')"
        [[ "$actual" == "$checksum" ]] || {
            echo "Checksum mismatch: $backup" >&2
            exit 1
        }
    fi
    if [[ -e "$target" || -L "$target" ]]; then
        echo "Refusing to overwrite existing target: $target" >&2
        exit 1
    fi
    printf '%s <- %s (%s)\n' "$target" "$backup" "$type"
done < "$MANIFEST"

if (( APPLY == 0 )); then
    echo "Restore plan verified. Re-run with --apply after unstowing affected packages."
    exit 0
fi

while IFS=$'\t' read -r target backup _type _checksum; do
    [[ "$target" == "target" ]] && continue
    mkdir -p "$(dirname "$target")"
    mv "$backup" "$target"
done < "$MANIFEST"

echo "Backup restored successfully."
