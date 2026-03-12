#!/bin/bash

# Plugin for AeroSpace workspace indicators
# Highlights the currently focused workspace

source "$CONFIG_DIR/colors.sh"

# Extract workspace ID from item name (e.g., "space.T" -> "T")
WORKSPACE_ID="${NAME##*.}"

if [ "$SENDER" = "aerospace_workspace_change" ]; then
  if [ "$WORKSPACE_ID" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set $NAME \
      icon.color=$WHITE \
      icon.highlight=on \
      background.color=$MAGENTA \
      background.drawing=on
  else
    sketchybar --set $NAME \
      icon.color=$GREY \
      icon.highlight=off \
      background.color=$TRANSPARENT \
      background.drawing=off
  fi
fi
