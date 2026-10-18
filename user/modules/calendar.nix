{
  theme,
  darkMode,
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  palette =
    if theme == "softlight"
    then {
      bg = "#f6f2ee";
      fg = "#3d2b5a";
      muted = "#837a72";
      surface = "#e4dcd4";
      border = "#d3c7bb";
    }
    else if darkMode
    then {
      bg = "#1d2021";
      fg = "#ebdbb2";
      muted = "#928374";
      surface = "#3c3836";
      border = "#504945";
    }
    else {
      bg = "#fbf1c7";
      fg = "#3c3836";
      muted = "#7c6f64";
      surface = "#ebdbb2";
      border = "#d5c4a1";
    };
  toggle = pkgs.writeShellApplication {
    name = "calendar-toggle";
    runtimeInputs = [pkgs.eww pkgs.hyprland pkgs.jq pkgs.coreutils];
    text = ''
      export EWW_CALENDAR_CONFIG=${lib.escapeShellArg "${config.xdg.configHome}/eww-calendar"}
      ${builtins.readFile ./calendar/toggle.sh}
    '';
  };
in {
  # Separate Eww configuration/daemon so future widgets can use ~/.config/eww.
  home.packages = [pkgs.eww toggle];
  xdg.configFile."eww-calendar/eww.yuck".source = ./calendar/eww.yuck;
  xdg.configFile."eww-calendar/eww.scss".text =
    builtins.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "$${name}: ${value};") palette)
    + "\n"
    + builtins.readFile ./calendar/eww.scss;

  home.file.".config/hypr/hyprland.conf".text = lib.mkAfter ''
    # A main-letter key plus the existing thumb modifier works well on Glove80.
    bind = $mainMod, A, exec, ${toggle}/bin/calendar-toggle
  '';
}
