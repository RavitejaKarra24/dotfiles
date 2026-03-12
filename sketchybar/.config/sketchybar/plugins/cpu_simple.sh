#!/bin/bash

source "$CONFIG_DIR/colors.sh"

CPU=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s}')

# Cap at 100 per core, but show total across all cores
# For display, we'll show the aggregate
if [ "$CPU" -ge 70 ]; then
  COLOR=$RED
elif [ "$CPU" -ge 30 ]; then
  COLOR=$ORANGE
elif [ "$CPU" -ge 10 ]; then
  COLOR=$YELLOW
else
  COLOR=$LABEL_COLOR
fi

sketchybar --set "$NAME" label="${CPU}%" label.color=$COLOR
