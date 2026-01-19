{
  pkgs,
  lib,
  ...
}: {
  # If you're currently using GDM:
  services.displayManager.gdm.enable = false;
  services.desktopManager.gnome.enable = false;

  # Keep this on for input/video drivers, etc. (the name is historical)
  services.xserver.enable = true;

  # Enable Hyprland system integration
  programs.hyprland.enable = true;

  # Greetd + tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # tuigreet runs as the greeter user, and then launches your session command
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.hyprland}/bin/Hyprland";
        user = "greeter";
      };
    };
  };

  # Some people also set this; harmless and often useful for Wayland apps
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
