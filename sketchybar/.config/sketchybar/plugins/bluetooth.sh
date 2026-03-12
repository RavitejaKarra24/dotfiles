#!/bin/bash

# Filename: ~/github/dotfiles-latest/sketchybar/felixkratz-linkarzu/plugins/bluetooth.sh
# Plugin for Bluetooth status indicator

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

# Check if Bluetooth is powered on
BT_STATUS=$(system_profiler SPBluetoothDataType 2>/dev/null | grep "State:" | head -1 | awk '{print $2}')

if [ "$BT_STATUS" = "On" ]; then
  # Check for connected devices
  CONNECTED_DEVICES=$(system_profiler SPBluetoothDataType 2>/dev/null | grep "Connected: Yes" | wc -l | tr -d ' ')
  if [ "$CONNECTED_DEVICES" -gt 0 ]; then
    sketchybar --set $NAME icon=$BLUETOOTH icon.color=$BLUE label="${CONNECTED_DEVICES}" label.drawing=on
  else
    sketchybar --set $NAME icon=$BLUETOOTH icon.color=$WHITE label.drawing=off
  fi
else
  sketchybar --set $NAME icon=$BLUETOOTH icon.color=$GREY label.drawing=off
fi
