{
  description = "My System Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # Home Manager input
    home-manager.url = "github:nix-community/home-manager";
    # make Home Manager follow the same nixpkgs revision
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager }: {
    nixosConfigurations.pj-laptop = nixpkgs.lib.nixosSystem {
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

        # Enable Home Manager as a NixOS module:
        # this exposes `home-manager` options such as `home-manager.users.<username> = { ... };`
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
