#!/usr/bin/env bash
# fullscreen_toggle.sh - toggle fullscreen move/undo for focused window
set -euo pipefail

DB="${XDG_STATE_HOME:-$HOME/.local/state}/hypr/fullscreen_move_db.json"
MOVE="$HOME/.config/hypr/scripts/fullscreen_move.sh"
UNDO="$HOME/.config/hypr/scripts/fullscreen_undo.sh"

command -v hyprctl >/dev/null 2>&1 || { echo "hyprctl not found" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq not found" >&2; exit 1; }

# get focused client address
addr=$(hyprctl -j activewindow 2>/dev/null | jq -r '.address? // empty' 2>/dev/null || true)
if [ -z "$addr" ]; then
  echo "Could not determine focused window address." >&2
  exit 1
fi

# decide whether to undo or move
if [ -f "$DB" ] && jq -e --arg a "$addr" 'has($a)' "$DB" >/dev/null 2>&1; then
    exec "$UNDO"
else
    exec "$MOVE"
fi

