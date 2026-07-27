#!/usr/bin/env bash

set -u
umask 077

PREV_FILE="${TMPDIR:-/tmp}/sketchybar_net_prev_${UID}"
NOW=$(date +%s)

INTERFACE=$(route -n get default 2>/dev/null | awk '/interface:/{print $2; exit}')
if [[ -z "$INTERFACE" ]]; then
  sketchybar --set "$NAME" label="--"
  exit 0
fi

CURRENT_BYTES=$(netstat -I "$INTERFACE" -b 2>/dev/null | awk 'NR > 1 {value=$7} END {print value}')
if [[ ! "$CURRENT_BYTES" =~ ^[0-9]+$ ]]; then
  sketchybar --set "$NAME" label="--"
  exit 0
fi

DISPLAY="0 B/s"
if [[ -r "$PREV_FILE" ]]; then
  read -r PREV_TIME PREV_BYTES PREV_INTERFACE < "$PREV_FILE"
  if [[ "$PREV_TIME" =~ ^[0-9]+$ && "$PREV_BYTES" =~ ^[0-9]+$ && "$PREV_INTERFACE" == "$INTERFACE" ]]; then
    ELAPSED=$((NOW - PREV_TIME))
    DIFF=$((CURRENT_BYTES - PREV_BYTES))
    if (( ELAPSED > 0 && DIFF >= 0 )); then
      RATE=$((DIFF / ELAPSED))
      DISPLAY=$(awk -v rate="$RATE" 'BEGIN {
        if (rate >= 1073741824) printf "%.1f GB/s", rate / 1073741824
        else if (rate >= 1048576) printf "%.1f MB/s", rate / 1048576
        else if (rate >= 1024) printf "%.1f KB/s", rate / 1024
        else printf "%d B/s", rate
      }')
    fi
  fi
fi

sketchybar --set "$NAME" label="$DISPLAY"
TEMP_FILE="${PREV_FILE}.$$"
printf '%s %s %s\n' "$NOW" "$CURRENT_BYTES" "$INTERFACE" > "$TEMP_FILE"
mv -f "$TEMP_FILE" "$PREV_FILE"
