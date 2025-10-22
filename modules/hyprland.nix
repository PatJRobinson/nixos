{ pkgs, ...}:

{
  environment.variables = {
    "QT_QPA_PLATFORM" = "wayland";
    "QT_USE_NATIVE_BORDER" = "1";
    "NIXOS_OZONE_WL"="1";
  };

  # hyprland config
  programs.hyprland.enable = true; # enable Hyprland

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  environment.systemPackages = with pkgs; [
    wlsunset
    dunst
    hyprlock
    rofi
  ];
}
