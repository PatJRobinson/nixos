{lib, pkgs, ...}: let
  # wlogout copies label text directly from its tokenizer without decoding JSON
  # escapes. Use literal line breaks rather than the escaped output of toJSON.
  layout = pkgs.writeText "battery-warning-layout" ''
    {
      "label": "battery-critical",
      "action": "true",
      "text": "BATTERY CRITICALLY LOW

    5% or less remaining.
    Connect your charger now.

    Escape to dismiss"
    }
  '';
  warning = pkgs.writeShellApplication {
    name = "battery-warning";
    runtimeInputs = [pkgs.util-linux pkgs.wlogout];
    text = ''
      # Keep preview and automatic warnings from opening duplicate overlays.
      exec 9>"$XDG_RUNTIME_DIR/battery-warning-overlay.lock"
      flock -n 9 || exit 0
      export GDK_BACKEND=wayland
      wlogout --protocol layer-shell --buttons-per-row 1 --margin 48 \
        --layout ${layout} --css ${./battery-warning/style.css}
    '';
  };
  monitor = pkgs.writeShellApplication {
    name = "battery-warning-monitor";
    runtimeInputs = [pkgs.coreutils warning];
    text = builtins.readFile ./battery-warning/monitor.sh;
  };
  start = pkgs.writeShellApplication {
    name = "battery-warning-start";
    runtimeInputs = [pkgs.systemd];
    text = ''
      # This Hyprland configuration starts applications directly rather than
      # using a systemd-managed compositor session. Pass its display to the service.
      systemctl --user import-environment WAYLAND_DISPLAY
      systemctl --user restart battery-warning.service
    '';
  };
in {
  home.packages = [warning start];

  systemd.user.services.battery-warning = {
    Unit = {
      Description = "Fullscreen warning when an internal battery reaches 5%";
      ConditionPathExistsGlob = "/sys/class/power_supply/*/capacity";
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${monitor}/bin/battery-warning-monitor";
      Restart = "on-failure";
      RestartSec = 15;
    };
  };

  home.file.".config/hypr/hyprland.conf".text = lib.mkAfter ''
    # The service exits without polling on hosts without an internal battery.
    exec-once = ${start}/bin/battery-warning-start
  '';
}
