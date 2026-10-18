{
  lib,
  pkgs,
  hostParams,
  config,
  ...
}: let
  # Dayfox palette for browser and desktop surfaces.
  # Inspiration: https://github.com/mohsilas/softlight_rice
  p = {
    bg = "f6f2ee";
    surface = "e4dcd4";
    fg = "3d2b5a";
    muted = "837a72";
    border = "d3c7bb";
    selection = "e7d2be";
    red = "a5222f";
    green = "396847";
    yellow = "ac5402";
    blue = "2848a9";
    purple = "6e33ce";
    cyan = "287980";
  };
  wallpaper = pkgs.runCommand "softlight-wallpaper" {nativeBuildInputs = [pkgs.librsvg];} ''
    mkdir -p "$out"
    rsvg-convert -w 3840 -h 2160 ${./softlight/wallpaper.svg} -o "$out/softlight.png"
  '';
in {
  home.sessionVariables = {
    NVIM_DARK_MODE = lib.mkForce "0";
    NVIM_COLOURSCHEME = "dayfox";
  };
  home.packages = [pkgs.nerd-fonts.jetbrains-mono];
  # Lazy resets runtimepath/packpath, hiding Home Manager's plugin directory.
  # It retains stdpath("data")/site: expose the theme there so both the existing
  # NVIM_COLOURSCHEME hook and Telescope's colorscheme picker can find it.
  xdg.dataFile = {
    "nvim/site/colors".source = "${pkgs.vimPlugins.nightfox-nvim}/colors";
    "nvim/site/lua/nightfox".source = "${pkgs.vimPlugins.nightfox-nvim}/lua/nightfox";
  };

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3";
      package = pkgs.adw-gtk3;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = false;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = false;
    gtk4.theme = config.gtk.theme;
  };
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-light";

  home.file =
    {
      "wallpapers/".source = lib.mkForce wallpaper;
      ".config/ghostty/config".text = lib.mkForce ''
        # Keep the Softlight background, with the previous Gruvbox Light Hard
        # foreground and ANSI palette for terminal text.
        theme = Gruvbox Light Hard
        background = #f6f2ee
        font-family = JetBrainsMono Nerd Font
        font-size = 12
        background-opacity = 1
        window-padding-x = 18
        window-padding-y = 16
        app-notifications = no-clipboard-copy
      '';
      ".local/firejail/qute-casual/.config/qutebrowser/config.py".text = lib.mkForce (
        ''
          bg0_hard = "#${p.bg}"
          bg0_soft = "#${p.bg}"
          bg0_normal = "#${p.bg}"
          bg0 = "#${p.bg}"
          bg1 = "#${p.bg}"
          bg2 = "#${p.surface}"
          bg3 = "#${p.border}"
          bg4 = "#${p.selection}"
          fg0 = "#${p.fg}"
          fg1 = "#${p.fg}"
          fg2 = "#643f61"
          fg3 = "#${p.muted}"
          fg4 = "#${p.muted}"
          bright_red = dark_red = "#${p.red}"
          bright_green = dark_green = "#${p.green}"
          bright_yellow = dark_yellow = "#${p.yellow}"
          bright_blue = dark_blue = "#${p.blue}"
          bright_purple = dark_purple = "#${p.purple}"
          bright_aqua = dark_aqua = "#${p.cyan}"
          bright_gray = dark_gray = "#${p.muted}"
          bright_orange = dark_orange = "#955f61"
        ''
        + builtins.readFile ../qutebrowser/config.py
        + ''
          c.colors.webpage.darkmode.enabled = False
          config.load_autoconfig(False)
        ''
      );
    }
    // lib.optionalAttrs (hostParams.wm.type == "hypr") {
      ".config/rofi".source = lib.mkForce ./softlight/rofi;
      # Keep every Waybar module, click action and script in the original config.
      ".config/waybar/style.css".source = lib.mkForce ./softlight/waybar.css;
      ".config/hypr/hyprland.conf".text = lib.mkAfter ''
        # Softlight appearance; existing monitors, layouts, rules and bindings above.
        general {
            gaps_in = 8
            gaps_out = 18
            border_size = 1
            col.active_border = rgb(${p.border})
            col.inactive_border = rgb(${p.surface})
        }
        decoration {
            rounding = 14
            shadow {
                enabled = true
                range = 28
                render_power = 3
                color = rgba(352c2426)
            }
        }
      '';
      ".config/hypr/hyprlock.conf".source = lib.mkForce ./softlight/hyprlock.conf;
    };
}
