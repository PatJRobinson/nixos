eww_command=(eww --force-wayland --config "$EWW_CALENDAR_CONFIG")
case "${1:-}" in
  --close)
    "${eww_command[@]}" close date
    exit 0
    ;;
  ""|--pointer) ;;
  *) echo "Usage: calendar-toggle [--pointer|--close]" >&2; exit 2 ;;
esac

# Use the focused output for the keybind, or the clicked output for Waybar.
monitors=$(hyprctl monitors -j)
monitor=$(jq -ce 'map(select(.focused))[0] // .[0]' <<< "$monitors")
horizontal=0
if [[ "${1:-}" == --pointer ]]; then
  pointer=$(hyprctl cursorpos -j)
  monitor=$(jq -ce --argjson pointer "$pointer" '
    def logical_width: (if .transform % 2 == 1 then .height else .width end) / .scale;
    def logical_height: (if .transform % 2 == 1 then .width else .height end) / .scale;
    map(select($pointer.x >= .x and $pointer.x < (.x + logical_width)
      and $pointer.y >= .y and $pointer.y < (.y + logical_height)))[0]
      // map(select(.focused))[0] // .[0]
  ' <<< "$monitors")
  # Centre below the clock click, keeping the 320px popup inside the output.
  horizontal=$(jq -nr --argjson pointer "$pointer" --argjson monitor "$monitor" '
    ($monitor | (if .transform % 2 == 1 then .height else .width end) / .scale) as $width
    | (($pointer.x - $monitor.x) | [., ($width - 168)] | min | [., 168] | max)
      - ($width / 2) | round
  ')
fi
screen=$(jq -r '.name' <<< "$monitor")

# Follow the actual bar height in logical pixels, including HiDPI displays.
layers=$(hyprctl layers -j)
vertical=$(jq -r --arg screen "$screen" '
  [.[$screen].levels[]?[]? | select(.namespace == "waybar") | .h]
  | (max // 38) + 8 | round
' <<< "$layers")

# Eww's open command starts its daemon on demand; no autostart or sleep needed.
# Each new opening resets the calendar to today, while month navigation stays local.
"${eww_command[@]}" open date --toggle \
  --arg "screen=$screen" --arg "x=$horizontal" --arg "y=$vertical" \
  --arg "today_day=$(date +%-d)" --arg "today_month=$(date +%-m)" \
  --arg "today_year=$(date +%Y)" --arg "today_label=$(date '+%A, %-d %B %Y')"
