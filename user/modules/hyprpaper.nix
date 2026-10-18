{config, lib, pkgs, ...}: let
  prepare = pkgs.writeShellApplication {
    name = "hyprpaper-prepare";
    runtimeInputs = [pkgs.coreutils pkgs.findutils];
    text = builtins.readFile ./hyprpaper/prepare.sh;
  };
  start = pkgs.writeShellApplication {
    name = "hyprpaper-start";
    runtimeInputs = [pkgs.systemd];
    text = ''
      # Hyprland is launched directly by greetd, without a managed session target.
      # Replace any instance left over from the previous compositor connection.
      systemctl --user import-environment WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE
      systemctl --user restart hyprpaper.service
    '';
  };
in {
  home.packages = [start];
  services.hyprpaper.enable = true;

  systemd.user.services.hyprpaper = {
    # Hyprland explicitly starts this service with its current environment.
    # Do not also start it through the unused graphical-session.target.
    Install.WantedBy = lib.mkForce [];
    Unit.After = lib.mkForce [];
    Unit.PartOf = lib.mkForce [];
    Service = {
      RuntimeDirectory = "hyprpaper";
      RuntimeDirectoryMode = "0700";
      # Use the theme's store directory directly, independent of home symlink timing.
      ExecStartPre = "${prepare}/bin/hyprpaper-prepare ${lib.escapeShellArg (toString config.home.file."wallpapers/".source)} %t/hyprpaper/hyprpaper.conf";
      ExecStart = lib.mkForce "${config.services.hyprpaper.package}/bin/hyprpaper --config %t/hyprpaper/hyprpaper.conf";
      Restart = lib.mkForce "on-failure";
    };
  };

  home.file.".config/hypr/hyprland.conf".text = lib.mkAfter ''
    # Select the wallpaper before starting the session's single Hyprpaper instance.
    exec-once = ${start}/bin/hyprpaper-start
  '';
}
