{...}: {
  system.stateVersion = "25.05";
  imports = [
    ./hardware-configuration.nix
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
          sha256 = "sha256:18czwjnzd5vp5dsk88iq0dsx97mhdygwmyxf8xi8mdrfpraaigpv";
        }
        + "/modules"
    )
  ];
  nix.settings.experimental-features = ["nix-command" "flakes"];
}
