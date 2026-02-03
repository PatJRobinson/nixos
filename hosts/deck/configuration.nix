{...}: {
  system.stateVersion = "25.05";
  imports = [
    ./hardware-configuration.nix
    ../../modules/home-manager.nix
    ../../modules/open-ssh.nix
    ../../modules/bootloader.nix
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
    (
      # Put the most recent revision here:
      let
        revision = "development";
      in
        builtins.fetchTarball {
          url = "https://github.com/Jovian-Experiments/Jovian-NixOS/archive/${revision}.tar.gz";
          # Update the hash as needed:
          sha256 = "sha256:0wl2hz8b8wryixd08lf66gl8ijxqaz2682f8j1l75jmz3258nb7s";
        }
        + "/modules"
    )
  ];
  jovian.devices.steamdeck.enable = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
}
