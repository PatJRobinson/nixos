# Calendar popup

Home Manager installs Eww and `calendar-toggle` for Hyprland hosts. Press
**Alt+A** to open or close the popup on the focused monitor, beneath Waybar's
central clock area. This uses the existing Alt modifier and a main-letter key
on the Glove80, without a function layer or a three-key chord.

Clicking the Waybar clock opens the same popup below the click on that output.
The position follows Waybar's reported height and the monitor's scaling. The
window overlays other windows without reserving space in the tiled layout.

The calendar opens on today and provides month navigation and week numbers.
Close it with Alt+A, another clock click, or its × button. Colours follow the
selected desktop theme; Softlight uses cream, purple, and square borders.

After applying Home Manager, Hyprland reloads the binding. If Waybar is already
running, restart it to pick up its updated clock click action. You can also run
`calendar-toggle` directly. Eww starts lazily when opening the calendar.

The widget uses its own `~/.config/eww-calendar` configuration and Eww daemon.
For diagnostics: `eww --config ~/.config/eww-calendar logs`.
