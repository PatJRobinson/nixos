#!/usr/bin/env bash
# fullscreen_undo.sh - move focused window back to its original workspace and un-fullscreen
set -euo pipefail

command -v hyprctl >/dev/null 2>&1 || { echo "hyprctl not found" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq not found" >&2; exit 1; }

DB="${XDG_STATE_HOME:-$HOME/.local/state}/hypr/fullscreen_move_db.json"

# get focused client address (robust)
addr=$(hyprctl -j activewindow 2>/dev/null | jq -r '.address? // empty' 2>/dev/null || true)
if [ -z "$addr" ]; then
  addr=$(hyprctl -j clients 2>/dev/null \
    | jq -r '
      (if (type == "object" and has("clients")) then .clients
       elif (type == "array") then .
       else [] end)
      | map({addr:.address, focus:.focusHistoryID?//-1})
      | max_by(.focus).addr? // empty
    ' 2>/dev/null || true)
fi

if [ -z "$addr" ]; then
  echo "Could not determine focused window address." >&2
  exit 1
fi

if [ ! -f "$DB" ]; then
  echo "No DB at $DB; nothing to undo." >&2
  exit 1
fi

orig_ws=$(jq -r --arg a "$addr" '.[$a] // empty' "$DB" 2>/dev/null || true)

if [ -z "$orig_ws" ]; then
  echo "No recorded original workspace for $addr; nothing to undo." >&2
  exit 1
fi

# Move the focused window back to the original workspace and un-fullscreen it
hyprctl dispatch movetoworkspace "$orig_ws"
sleep 0.05

# If it's fullscreen, toggle fullscreen off (this toggles for the focused client)
hyprctl dispatch fullscreen 0

# remove the DB entry for this client
tmp="$(mktemp)"
jq -r --arg a "$addr" 'del(.[$a])' "$DB" > "$tmp" && mv "$tmp" "$DB"

# if DB is now empty, remove file (nice cleanup)
if [ "$(jq -r 'keys | length' "$DB")" -eq 0 ] 2>/dev/null || [ "$(jq -r 'length' "$DB")" -eq 0 ] 2>/dev/null; then
  rm -f "$DB"
fi

exit 0

