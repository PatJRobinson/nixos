{
  description = "My System Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.pj-desktop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
        ./bootloader.nix
        ./time-zone.nix
        ./auto-upgrade.nix
        ./display-manager.nix
        ./networking.nix
        ./firewall.nix
        ./sunshine.nix
        ./open-ssh.nix
        ./terminal.nix
        ./steam.nix
        ./hyprland.nix
        ./users.nix
        ./browsers.nix
        ./audio.nix
        ./fonts.nix
        ./docker.nix
        ./text-editing.nix
        ./rust.nix
        ./cpp.nix
        ./moonlight.nix
        ./files.nix
        ./office.nix
        ./notifications.nix
      ];
    };
  };
}
