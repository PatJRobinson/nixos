{pkgs, ...}:

let
  braveWayland = pkgs.writeShellScriptBin "brave-wayland" ''
    exec ${pkgs.brave}/bin/brave \
      --enable-features=UseOzonePlatform \
      --ozone-platform=wayland \
      "$@"
  '';
  ungoogledChromiumWayland = pkgs.writeShellScriptBin "ungoogled-chromium-wayland" ''
    exec ${pkgs.ungoogled-chromium}/bin/chromium \
      --enable-features=UseOzonePlatform \
      --ozone-platform=wayland \
      "$@"
  '';
  in
{
  # Install firefox.
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    brave
    braveWayland
    ungoogled-chromium
    ungoogledChromiumWayland
  ];
}
