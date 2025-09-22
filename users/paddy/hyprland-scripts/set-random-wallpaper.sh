#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/wallpapers/"
CURRENT_WALL=$(hyprctl hyprpaper listloaded)

# Find all wallpaper files
WALLPAPERS=($(find "$WALLPAPER_DIR" -type f))
WALLPAPER_COUNT=${#WALLPAPERS[@]}

if [[ $WALLPAPER_COUNT -eq 0 ]]; then
    echo "No wallpapers found in $WALLPAPER_DIR"
    exit 1
elif [[ $WALLPAPER_COUNT -eq 1 ]]; then
    WALLPAPER="${WALLPAPERS[0]}"
else
    # Get a random wallpaper that is not the current one
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f ! -name "$(basename "$CURRENT_WALL")" | shuf -n 1)
fi

# Apply the selected wallpaper
hyprctl hyprpaper reload ,"$WALLPAPER"
