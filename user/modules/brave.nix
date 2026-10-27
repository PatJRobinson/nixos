{
  config,
  pkgs,
  ...
}: let
  # Share Firefox's Dayfox palette, including the original Brave theme colours.
  p = builtins.fromJSON (builtins.readFile ./firefox/dayfox.json);
  theme = {
    manifest_version = 3;
    name = "Dayfox for Brave";
    version = "1.0.0";
    description = "Dayfox colour theme for Brave";
    theme.colors = {
      frame = p.surface;
      frame_inactive = p.border;
      toolbar = p.background;
      tab_text = p.foreground;
      tab_background_text = p.muted;
      bookmark_text = p.foreground;
      toolbar_button_icon = p.foreground;
      omnibox_background = p.surface;
      omnibox_text = p.foreground;
      ntp_background = p.background;
      ntp_text = p.foreground;
      ntp_link = p.blue;
    };
  };
  initialPreferences = pkgs.writeText "brave-linkedin-preferences.json" (builtins.toJSON {
    profile = {
      name = "linkedin";
      using_default_name = false;
    };
    browser.check_default_browser = false;
  });
  initialLocalState = pkgs.writeText "brave-linkedin-local-state.json" (builtins.toJSON {
    profile = {
      last_used = "linkedin";
      info_cache.linkedin = {
        name = "linkedin";
        is_using_default_name = false;
        avatar_icon = "chrome://theme/IDR_PROFILE_AVATAR_0";
        is_using_default_avatar = true;
      };
    };
  });
  linkedin = pkgs.writeShellScriptBin "brave-linkedin" ''
    # A separate user-data directory keeps the Wayland app ID and theme
    # independent of other Brave windows, including an existing running browser.
    data_dir="${config.xdg.configHome}/BraveSoftware/Brave-LinkedIn"
    profile_dir="$data_dir/linkedin"
    ${pkgs.coreutils}/bin/mkdir -p -m 700 "$profile_dir"
    # Seed the profile picker and visible name once; Brave owns them thereafter.
    if [[ ! -e "$data_dir/Local State" ]]; then
      ${pkgs.coreutils}/bin/install -m 600 ${initialLocalState} "$data_dir/Local State"
    fi
    if [[ ! -e "$profile_dir/Preferences" ]]; then
      ${pkgs.coreutils}/bin/install -m 600 ${initialPreferences} "$profile_dir/Preferences"
    fi
    if [[ "$#" -eq 0 ]]; then
      set -- "https://www.linkedin.com/"
    fi
    exec ${config.programs.brave.finalPackage}/bin/brave \
      --ozone-platform=wayland \
      --user-data-dir="$data_dir" \
      --profile-directory=linkedin \
      --class=brave-linkedin \
      --load-extension="${config.xdg.configHome}/brave-dayfox" \
      --no-first-run \
      --no-default-browser-check \
      "$@"
  '';
in {
  programs.brave.enable = true;
  home.packages = [linkedin];

  # Keep the unpacked theme's path stable across rebuilds.
  xdg.configFile."brave-dayfox/manifest.json".text = builtins.toJSON theme;
  home.file.".local/share/icons/hicolor/scalable/apps/brave-linkedin.svg".source = ./application-icons/brave-linkedin.svg;

  xdg.desktopEntries.brave-linkedin = {
    name = "Brave (LinkedIn)";
    genericName = "LinkedIn";
    comment = "LinkedIn in a dedicated Dayfox Brave profile";
    exec = "${linkedin}/bin/brave-linkedin %U";
    icon = "brave-linkedin";
    terminal = false;
    categories = ["Network" "WebBrowser"];
    settings = {
      StartupWMClass = "brave-linkedin";
      Keywords = "linkedin;";
    };
  };
}
