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
  cursorTheme = import ./softlight/cursor.nix {
    inherit pkgs;
    foreground = p.fg;
    outline = p.bg;
  };
  waybarIcons = pkgs.runCommand "softlight-waybar-icons" {
    nativeBuildInputs = [pkgs.imagemagick pkgs.gtk3 pkgs.perl];
    propagatedBuildInputs = [pkgs.gruvbox-plus-icons];
  } ''
    mkdir -p "$out/share/icons/Softlight-Monochrome"
    cp ${pkgs.gruvbox-plus-icons}/share/icons/Gruvbox-Plus-Dark/index.theme "$out/share/icons/Softlight-Monochrome/"
    # Keep the theme's relative alias symlinks; dereferencing them recursively
    # expands the 5,127 source SVGs into more than 90,000 copies.
    cp -r ${pkgs.gruvbox-plus-icons}/share/icons/Gruvbox-Plus-Dark/apps "$out/share/icons/Softlight-Monochrome/apps"
    chmod -R u+w "$out/share/icons/Softlight-Monochrome"

    # The large variants have opaque tiles: tinting their foreground and
    # background alike hides the logo. Use the transparent small SVG artwork
    # at every size, including the 32/48px aliases used on scaled displays.
    rm -rf "$out/share/icons/Softlight-Monochrome/apps/scalable"
    ln -s 16 "$out/share/icons/Softlight-Monochrome/apps/scalable"

    # Reuse the original theme for everything outside application icons.
    sed -i 's/^Inherits=.*/Inherits=Gruvbox-Plus-Dark,hicolor/' "$out/share/icons/Softlight-Monochrome/index.theme"

    # Preserve icon alpha while replacing each raster icon's color with Softlight's foreground.
    raster_icons="$out/share/icons/Softlight-Monochrome"
    raster_total=$(find "$raster_icons" -type f \( -iname '*.png' -o -iname '*.webp' -o -iname '*.xpm' \) | wc -l)
    echo "Recoloring $raster_total raster app icons"
    raster_count=0
    find "$raster_icons" -type f \( -iname '*.png' -o -iname '*.webp' -o -iname '*.xpm' \) -print0 |
      while IFS= read -r -d $'\0' icon; do
        magick "$icon" -channel RGB -fill '#3d2b5a' -colorize 100 "$icon"
        raster_count=$((raster_count + 1))
        if (( raster_count % 50 == 0 || raster_count == raster_total )); then
          echo "Recolored $raster_count/$raster_total raster app icons"
        fi
      done

    # Keep SVGs scalable while replacing their explicit fill and stroke colors.
    svg_total=$(find "$out/share/icons/Softlight-Monochrome" -type f -iname '*.svg' | wc -l)
    echo "Recoloring $svg_total scalable app icons"
    find "$out/share/icons/Softlight-Monochrome" -type f -iname '*.svg' -print0 |
      xargs -0 -r -n 256 perl -0pi -e 's/\b(fill|stroke|stop-color|color)="(?!none\b|currentColor\b|url\()[^"]+"/$1="#3d2b5a"/gi; s/\b(fill|stroke|stop-color|color)\s*:\s*(?!none\b|currentColor\b|url\()[^;}]+/$1:#3d2b5a/gi'
    echo "Recolored $svg_total/$svg_total scalable app icons"

    # A transparent G keeps its shape when tinted, unlike the icon pack's tile.
    for size in 16 scalable; do
      sed 's/#4285f4/#${p.fg}/g' ${./application-icons/brave-google.svg} \
        > "$out/share/icons/Softlight-Monochrome/apps/$size/brave-google.svg"
    done

    sed -i 's/^Name=.*/Name=Softlight Monochrome/' "$out/share/icons/Softlight-Monochrome/index.theme"
    gtk-update-icon-cache -f "$out/share/icons/Softlight-Monochrome"
  '';
in {
  home.sessionVariables = {
    NVIM_DARK_MODE = lib.mkForce "0";
    NVIM_COLOURSCHEME = "dayfox";
  };
  home.packages = [pkgs.nerd-fonts.jetbrains-mono waybarIcons];
  home.pointerCursor = {
    enable = true;
    package = cursorTheme;
    name = "Softlight-Purple";
    size = 24;
    gtk.enable = true;
    hyprcursor.enable = true;
  };
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
      ".local/share/icons/hicolor/scalable/apps/brave-google.svg".source = lib.mkForce "${waybarIcons}/share/icons/Softlight-Monochrome/apps/scalable/brave-google.svg";
      # Keep every Waybar module, click action and script in the original config.
      ".config/waybar/style.css".source = lib.mkForce ./softlight/waybar.css;
      ".config/waybar/config".source = lib.mkForce (pkgs.writeText "waybar-softlight-config" (
        builtins.replaceStrings
          ["\"icon-theme\": \"Gruvbox-Plus-Dark\""]
          ["\"icon-theme\": \"Softlight-Monochrome\""]
          (builtins.readFile ../waybar/config)
      ));
      ".config/hypr/hyprland.conf".text = lib.mkAfter ''
        env = HYPRCURSOR_THEME,Softlight-Purple
        env = XCURSOR_THEME,Softlight-Purple
        # Softlight appearance; existing monitors, layouts, rules and bindings above.
        general {
            gaps_in = 0
            gaps_out = 0
            border_size = 1
            col.active_border = rgb(${p.fg})
            col.inactive_border = rgb(${p.surface})
        }
        decoration {
            rounding = 0
            shadow {
                enabled = false
            }
        }
      '';
      ".config/hypr/hyprlock.conf".source = lib.mkForce ./softlight/hyprlock.conf;
    };
}
