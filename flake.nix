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
    nixosConfigurations = {
      pj-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/pj-laptop/configuration.nix
        ];
      };
    }
  };
}
