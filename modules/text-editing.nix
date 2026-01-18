{pkgs, ...}: let
  obsidianWayland = pkgs.writeShellScriptBin "obsidian-wayland" ''
    exec ${pkgs.obsidian}/bin/obsidian \
      --enable-features=UseOzonePlatform \
      --ozone-platform=wayland \
      "$@"
  '';
in {
  environment.systemPackages = with pkgs; [
    neovim
    obsidianWayland
  ];
}
