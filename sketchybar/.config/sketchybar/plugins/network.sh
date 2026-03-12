#!/bin/bash

PREV_FILE="/tmp/sketchybar_net_prev"

# Get current bytes received on the primary interface
INTERFACE=$(route -n get default 2>/dev/null | grep interface | awk '{print $2}')
if [ -z "$INTERFACE" ]; then
  sketchybar --set "$NAME" label="--"
  exit 0
fi

CURRENT_BYTES=$(netstat -I "$INTERFACE" -b 2>/dev/null | tail -1 | awk '{print $7}')

if [ -z "$CURRENT_BYTES" ]; then
  sketchybar --set "$NAME" label="--"
  exit 0
fi

if [ -f "$PREV_FILE" ]; then
  PREV_BYTES=$(cat "$PREV_FILE")
  DIFF=$((CURRENT_BYTES - PREV_BYTES))

  # update_freq is 2 seconds, so divide by 2 for per-second rate
  RATE=$((DIFF / 2))

  if [ "$RATE" -lt 0 ]; then
    RATE=0
  fi

  if [ "$RATE" -gt 1073741824 ]; then
    DISPLAY=$(echo "scale=1; $RATE / 1073741824" | bc)" GB/s"
  elif [ "$RATE" -gt 1048576 ]; then
    DISPLAY=$(echo "scale=1; $RATE / 1048576" | bc)" MB/s"
  elif [ "$RATE" -gt 1024 ]; then
    DISPLAY=$(echo "scale=1; $RATE / 1024" | bc)" KB/s"
  else
    DISPLAY="${RATE} B/s"
  fi

  sketchybar --set "$NAME" label="$DISPLAY"
else
  sketchybar --set "$NAME" label="0 B/s"
fi

echo "$CURRENT_BYTES" > "$PREV_FILE"
