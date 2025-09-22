{ pkgs, ...}:

{
  # hyprland config
  programs.hyprland.enable = true; # enable Hyprland

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  environment.systemPackages = with pkgs; [
    hyprpaper
    wlsunset
    dunst
    hyprlock
    rofi
  ];
}
