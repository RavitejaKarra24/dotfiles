#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/items/bluetooth.sh
# Shows bluetooth status icon on the right side

bluetooth=(
  icon=$BLUETOOTH
  icon.font="$FONT:Bold:16.0"
  icon.color=$BLUE
  padding_right=5
  padding_left=5
  label.drawing=off
  update_freq=30
  script="$PLUGIN_DIR/bluetooth.sh"
  click_script="open /System/Library/PreferencePanes/Bluetooth.prefPane"
)

sketchybar --add item bluetooth right \
  --set bluetooth "${bluetooth[@]}"
