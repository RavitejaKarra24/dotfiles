#!/bin/bash

network=(
  icon=󰁅
  icon.font="$FONT:Bold:14.0"
  icon.color=$GREEN
  label.font="$FONT:Semibold:12.0"
  label.color=$LABEL_COLOR
  label="0 KB/s"
  padding_right=10
  update_freq=2
  updates=on
  script="$PLUGIN_DIR/network.sh"
)

sketchybar --add item network right \
  --set network "${network[@]}"
