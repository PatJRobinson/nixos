{...}: {
  system.stateVersion = "25.05";
  imports = [
    ../modules/home-manager.nix
    ../modules/audio.nix
    ../modules/caches.nix
    ../modules/bootloader.nix
    ../modules/bluetooth.nix
    ../modules/time-zone.nix
    ../modules/auto-upgrade.nix
    ../modules/display-manager.nix
    ../modules/networking.nix
    ../modules/firewall.nix
    ../modules/sunshine.nix # move to hm
    ../modules/open-ssh.nix
    ../modules/steam.nix
    ../modules/hyprland.nix
    ../modules/users.nix
    ../modules/browsers.nix # move to hm
    ../modules/fonts.nix
    ../modules/docker.nix
    ../modules/notifications.nix # move to hm
    ../modules/gc.nix
    ../modules/firejail.nix
    ../modules/filesystem.nix
    ../modules/power.nix
  ];
  nix.settings.experimental-features = ["nix-command" "flakes"];
  hardware.graphics.enable = true;
}
