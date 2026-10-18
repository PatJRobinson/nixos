{theme, darkMode}: {pkgs, ...}: let
  palette =
    if theme == "softlight"
    then {
      bg = "#f6f2ee";
      fg = "#3d2b5a";
      muted = "#837a72";
      border = "#d3c7bb";
      red = "#a5222f";
    }
    else if darkMode
    then {
      bg = "#1d2021";
      fg = "#ebdbb2";
      muted = "#928374";
      border = "#504945";
      red = "#cc241d";
    }
    else {
      bg = "#fbf1c7";
      fg = "#3c3836";
      muted = "#7c6f64";
      border = "#d5c4a1";
      red = "#9d0006";
    };
  normal = {
    background = palette.bg;
    foreground = palette.fg;
    frame_color = palette.border;
    timeout = 5;
  };
in {
  home.packages = [pkgs.nerd-fonts.jetbrains-mono];

  # Home Manager installs Dunst's D-Bus service; notify-send activates it as needed.
  services.dunst = {
    enable = true;
    settings = {
      global = {
        origin = "top-right";
        offset = "(18,60)";
        width = 360;
        height = "(0,200)";
        font = "JetBrainsMono Nerd Font 10";
        format = "<b>%s</b>\\n%b";
        markup = "full";
        alignment = "left";
        word_wrap = true;
        padding = 12;
        horizontal_padding = 16;
        text_icon_padding = 12;
        min_icon_size = 32;
        max_icon_size = 32;
        frame_width = 1;
        frame_color = palette.border;
        separator_height = 1;
        separator_color = palette.border;
        corner_radius = 0;
        transparency = 0;
      };
      urgency_low = normal // {foreground = palette.muted;};
      urgency_normal = normal;
      urgency_critical = normal // {
        frame_color = palette.red;
        timeout = 0;
      };
    };
  };
}
