{pkgs, ...}: let
  dayfoxTheme =
    pkgs.writeTextDir "manifest.json"
    (builtins.readFile ./brave-dayfox/manifest.json);

  braveWayland = pkgs.writeShellScriptBin "brave-wayland" ''
    # This runs inside Firejail's private home.
    themeDir="$HOME/.config/brave-dayfox"

    ${pkgs.coreutils}/bin/mkdir -p "$themeDir"
    ${pkgs.coreutils}/bin/install -m 644 \
      ${dayfoxTheme}/manifest.json \
      "$themeDir/manifest.json"

    exec ${pkgs.brave}/bin/brave \
      --enable-features=UseOzonePlatform \
      --ozone-platform=wayland \
      --load-extension="$themeDir" \
      "$@"
  '';
in {
  environment.systemPackages = with pkgs; [
    brave
    braveWayland
  ];

  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      brave-google = {
        executable = "${braveWayland}/bin/brave-wayland";
        profile = "${pkgs.firejail}/etc/firejail/brave.profile";
        extraArgs = [
          "--private=~/.local/firejail/brave-google"
          "--ignore=private-dev"
          "--env=GTK_THEME=Adwaita:dark"
          "--dbus-user.talk=org.freedesktop.Notifications"
        ];
      };
    };
  };
}
