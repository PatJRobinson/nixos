# Wallpaper startup

Hyprland runs `hyprpaper-start` once per session. It imports the current Wayland
display and Hyprland instance into the user service environment, then restarts
the single systemd-managed Hyprpaper instance. The service is started explicitly
rather than through `graphical-session.target`, which this configuration does
not start.

Before each daemon start, `prepare.sh` selects an image from the current theme's
Nix store wallpaper directory and writes a runtime config. Hyprpaper reads this
config at startup, including after automatic restarts. There is no IPC readiness
poll or delayed wallpaper-setting command. Selection happens once per start;
the wallpaper does not rotate on a timer.

After switching Home Manager configurations, run `hyprpaper-start` to use the
new setup immediately, or log out and back in. To choose another wallpaper
manually, `~/.local/bin/set-random-wallpaper.sh` remains available.
