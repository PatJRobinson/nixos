{ config, pkgs, ...}:

{
  system.stateVersion = "25.05";
  imports = [
    ./hardware-configuration.nix
    ../../modules/audio.nix
    ../../modules/bluetooth.nix
    ../../modules/caches.nix
    ../../modules/bootloader.nix
    ../../modules/time-zone.nix
    ../../modules/auto-upgrade.nix
    ../../modules/display-manager.nix
    ./modules/networking.nix
    ../../modules/firewall.nix
    ../../modules/sunshine.nix
    ../../modules/open-ssh.nix
    ../../modules/terminal.nix
    ../../modules/steam.nix
    ../../modules/hyprland.nix
    ../../modules/users.nix
    ../../modules/browsers.nix
    ../../modules/fonts.nix
    ../../modules/docker.nix
    ../../modules/text-editing.nix
    ../../modules/rust.nix
    ../../modules/cpp.nix
    ../../modules/moonlight.nix
    ../../modules/files.nix
    ../../modules/office.nix
    ../../modules/notifications.nix
    ../../modules/intel-graphics.nix
    ../../modules/monitoring.nix
    ../../modules/gc.nix
    ../../modules/firejail.nix
    ../../modules/filesystem.nix
    ../../modules/power.nix
    ../../modules/backlight.nix
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
