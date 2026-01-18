{...}: {
  system.stateVersion = "25.05";
  imports = [
    ./hardware-configuration.nix
    ../../modules/audio.nix
    ../../modules/bluetooth.nix
    ../../modules/caches.nix
    ../../modules/time-zone.nix
    ../../modules/auto-upgrade.nix
    ../../modules/gnome.nix
    ./modules/networking.nix
    ../../modules/firewall.nix
    ../../modules/steam.nix
    ../../modules/users.nix
    ../../modules/browsers.nix
    ../../modules/fonts.nix
    ../../modules/moonlight.nix
    ../../modules/monitoring.nix
    ../../modules/gc.nix
    ../../modules/filesystem.nix
    ../../modules/power.nix
  ];
  nix.settings.experimental-features = ["nix-command" "flakes"];
}
