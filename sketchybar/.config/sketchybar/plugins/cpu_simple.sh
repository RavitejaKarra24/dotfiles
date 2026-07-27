#!/bin/bash

source "$CONFIG_DIR/colors.sh"

CORES=$(sysctl -n hw.logicalcpu 2>/dev/null || echo 1)
CPU=$(ps -A -o %cpu | awk -v cores="$CORES" '
  { total += $1 }
  END {
    if (cores < 1) cores = 1
    printf "%.0f", total / cores
  }
')

# Normalize aggregate process CPU by the number of logical CPUs.
if [ "$CPU" -ge 70 ]; then
  COLOR=$RED
elif [ "$CPU" -ge 30 ]; then
  COLOR=$ORANGE
elif [ "$CPU" -ge 10 ]; then
  COLOR=$YELLOW
else
  COLOR=$LABEL_COLOR
fi

sketchybar --set "$NAME" label="${CPU}%" label.color="$COLOR"
