# Critical battery warning

The Hyprland Home Manager configuration imports `../battery-warning.nix`.
Its user service checks internal batteries every 15 seconds and displays a
fullscreen wlogout overlay when discharging at 5% or below. Peripheral batteries
are ignored, and the service exits on machines without an internal battery.

After applying Home Manager, preview the overlay from a Wayland terminal:

```sh
battery-warning
```

Press Escape or click the warning to close it. There is no timeout.
The overlay spans connected monitors; wlogout also permits dismissing it by
clicking the background.

Start monitoring immediately in the current Hyprland session:

```sh
battery-warning-start
systemctl --user status battery-warning.service
```

Hyprland starts the service automatically on subsequent logins. Acknowledgement
persists across service restarts within the login session. The warning rearms
once every detected internal battery is above 5%; launch failures are retried.
The preview command does not acknowledge the monitor's battery threshold.

This module does not suspend, hibernate or shut down the machine.
