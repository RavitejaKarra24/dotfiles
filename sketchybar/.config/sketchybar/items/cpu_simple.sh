#!/bin/bash

cpu_simple=(
  icon=󰻠
  icon.font="$FONT:Bold:16.0"
  icon.color=$BLUE
  label.font="$FONT:Semibold:12.0"
  label.color=$LABEL_COLOR
  label="0%"
  padding_right=8
  update_freq=4
  updates=on
  script="$PLUGIN_DIR/cpu_simple.sh"
)

sketchybar --add item cpu_simple right \
  --set cpu_simple "${cpu_simple[@]}"
