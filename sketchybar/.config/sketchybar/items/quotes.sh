#!/bin/bash

quotes=(
  icon.drawing=off
  label.font="$FONT:Semibold:12.0"
  label.color=$LABEL_COLOR
  padding_left=10
  width=900
  update_freq=1800
  updates=on
  script="$PLUGIN_DIR/quotes.sh"
)

sketchybar --add item quotes left \
  --set quotes "${quotes[@]}"
