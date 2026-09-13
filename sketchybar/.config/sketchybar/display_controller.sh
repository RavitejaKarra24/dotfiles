#!/usr/bin/env bash

set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SOURCE="$CONFIG_DIR/display_controller.c"
CACHE_DIR="${TMPDIR:-/tmp}/sketchybar-display-controller-${UID}"
BINARY="$CACHE_DIR/display_controller"

mkdir -p "$CACHE_DIR"

if [[ ! -x "$BINARY" || "$SOURCE" -nt "$BINARY" ]]; then
  BUILD="$BINARY.$$"
  trap 'rm -f "$BUILD"' EXIT
  /usr/bin/clang \
    -std=c11 \
    -O2 \
    -Wall \
    -Wextra \
    -framework ApplicationServices \
    "$SOURCE" \
    -o "$BUILD"
  mv "$BUILD" "$BINARY"
  trap - EXIT
fi

exec "$BINARY"
