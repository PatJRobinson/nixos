{ pkgs, ...}:

{
  # hyprland config
  programs.hyprland.enable = true; # enable Hyprland

  environment.systemPackages = with pkgs; [
    hyprpaper
    waybar
    wlsunset
    dunst
    hyprlock
    rofi
  ];
}
