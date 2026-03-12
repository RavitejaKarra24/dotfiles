#!/bin/bash

# Filename: ~/.config/sketchybar/items/aerospace.sh
# AeroSpace workspace indicators for SketchyBar
# Shows all workspaces on the left side, like Hyprland/i3

# Numeric workspaces first, then named ones
SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "B" "E" "M" "N" "P" "T" "V")

for ws in "${SPACE_ICONS[@]}"; do
  space=(
    icon="$ws"
    icon.font="$FONT:Bold:13.0"
    icon.padding_left=7
    icon.padding_right=7
    padding_left=1
    padding_right=1
    icon.color=$GREY
    icon.highlight_color=$WHITE
    label.drawing=off
    background.color=$TRANSPARENT
    background.corner_radius=5
    background.height=22
    background.border_width=0
    updates=on
    script="$PLUGIN_DIR/aerospace.sh"
    click_script="aerospace workspace $ws"
  )

  sketchybar --add item space.$ws left \
    --set space.$ws "${space[@]}" \
    --subscribe space.$ws aerospace_workspace_change
done
