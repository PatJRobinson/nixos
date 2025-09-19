{ pkgs, ...}: 

{
  fonts.packages = with pkgs; [
    font-awesome                # Font Awesome OTF (for waybar icons)
    nerd-fonts.fira-code       # example Nerd Font (use whichever nerd-fonts.* you want)
    noto-fonts                 # optional: general sans/fallback fonts
  ];
  # Make sure fontconfig is enabled so applications can discover fonts
  fonts.fontconfig.enable = true;
}
