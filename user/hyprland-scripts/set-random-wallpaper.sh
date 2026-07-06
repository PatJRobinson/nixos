#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="$HOME/wallpapers"

mapfile -d '' WALLPAPERS < <(find -L "$WALLPAPER_DIR" -type f -print0)

WALLPAPER_COUNT=${#WALLPAPERS[@]}

if (( WALLPAPER_COUNT == 0 )); then
  echo "No wallpapers found in $WALLPAPER_DIR" >&2
  exit 1
fi

CURRENT_WALL="$(hyprctl hyprpaper listloaded 2>/dev/null | head -n 1 || true)"

if (( WALLPAPER_COUNT == 1 )); then
  WALLPAPER="${WALLPAPERS[0]}"
else
  mapfile -d '' CANDIDATES < <(
    find -L "$WALLPAPER_DIR" -type f ! -path "$CURRENT_WALL" -print0
  )

  if (( ${#CANDIDATES[@]} == 0 )); then
    WALLPAPER="${WALLPAPERS[0]}"
  else
    WALLPAPER="$(printf '%s\0' "${CANDIDATES[@]}" | shuf -z -n 1 | tr -d '\0')"
  fi
fi

hyprctl hyprpaper wallpaper ",${WALLPAPER},cover"
