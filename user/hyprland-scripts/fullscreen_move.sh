#!/usr/bin/env bash
# fullscreen_move.sh - mover that records original workspace for undo
set -euo pipefail

command -v hyprctl >/dev/null 2>&1 || { echo "hyprctl not found" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq not found" >&2; exit 1; }

DB="${XDG_STATE_HOME:-$HOME/.local/state}/hypr/fullscreen_move_db.json"
mkdir -p "$(dirname "$DB")"

# -------------------------
# determine focused workspace id (wsid) - robust
wsid=$(hyprctl -j activewindow 2>/dev/null | jq -r '.workspace.id? // empty' 2>/dev/null || true)

if [ -z "$wsid" ]; then
  wsid=$(hyprctl -j clients 2>/dev/null \
    | jq -r '
        (if (type == "object" and has("clients")) then .clients
         elif (type == "array") then .
         else [] end)
        | (if length==0 then empty else max_by(.focusHistoryID?//-1) end)
        | .workspace.id? // empty
      ' 2>/dev/null || true)
fi

if [ -z "$wsid" ]; then
  wsid=$(hyprctl -j workspaces 2>/dev/null \
    | jq -r '(.[] | select(.focused==true) | .id) // empty' 2>/dev/null || true)
fi

if [ -z "$wsid" ]; then
  echo "Could not determine focused workspace id." >&2
  exit 1
fi

# -------------------------
# count clients on that workspace
count=$(hyprctl -j clients 2>/dev/null \
  | jq -r --arg ws "$wsid" '
      (if (type == "object" and has("clients")) then .clients
       elif (type == "array") then .
       else [] end)
      | map(.workspace.id? // null)
      | map(tostring)
      | map(select(. == $ws))
      | length
    ' 2>/dev/null || true)

if ! printf "%s" "$count" | grep -q '^[0-9]\+$'; then
  count=2
fi

# -------------------------
# get focused client's address so we can record it if we move it
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

# If only one window on workspace -> just toggle fullscreen
if [ "$count" -le 1 ]; then
  hyprctl dispatch fullscreen 0
  exit 0
fi

# Otherwise record original workspace for this window, then move it and fullscreen.
if [ -n "$addr" ]; then
  # store as string (works fine for lookup later)
  if [ -f "$DB" ]; then
    tmp="$(mktemp)"
    jq --arg a "$addr" --arg w "$wsid" '. + {($a): $w}' "$DB" > "$tmp" && mv "$tmp" "$DB"
  else
    printf '{"%s":"%s"}\n' "$addr" "$wsid" > "$DB"
  fi
fi

# Move to next empty workspace on same monitor and fullscreen
hyprctl dispatch --batch "movetoworkspaceclient emptynm; workspace emptynum; fullscreen address$addr"

#hyprctl dispatch movetoworkspace emptynm
#sleep 0.05
#hyprctl dispatch fullscreen 0

exit 0

