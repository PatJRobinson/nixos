{
  description = "My System Configuration";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # Home Manager input
    home-manager.url = "github:nix-community/home-manager";
    # make Home Manager follow the same nixpkgs revision
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = { self, nixpkgs-unstable, home-manager }:
    let
      system = "x86_64-linux";
    in {
    nixosConfigurations = {
      pj-laptop = nixpkgs-unstable.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/pj-laptop/configuration.nix
        ];
      };
    };
    homeConfigurations = {
      "paddy@pj-laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs-unstable { inherit system; };
        modules = [ ./users/paddy/home.nix ];
      };
    };
  };
}
