#!/usr/bin/env bash

# Default temperature values
ON_TEMP=4000
OFF_TEMP=6000

# Query the current temperature
CURRENT_TEMP=$(hyprctl hyprsunset temperature 2>/dev/null | grep -oE '[0-9]+')

if [[ "$CURRENT_TEMP" == "$OFF_TEMP" ]]; then
  hyprctl hyprsunset temperature $ON_TEMP
  notify-send --expire-time 2000 "  Nightlight screen temperature"
else
  hyprctl hyprsunset temperature $OFF_TEMP
  notify-send --expire-time 2000 "   Daylight screen temperature"
fi
