{
  description = "My System Configuration";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-25-05.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager-unstable.url = "github:nix-community/home-manager";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager-25-05.url = "github:nix-community/home-manager/release-25.05";
    home-manager-25-05.inputs.nixpkgs.follows = "nixpkgs-25-05";
  };

  outputs = { self, nixpkgs-unstable, nixpkgs-25-05, home-manager-unstable, home-manager-25-05 }:
    let
      system = "x86_64-linux";

      mkHome = { hm, hyprParams } : hm.lib.homeManagerConfiguration {
        pkgs = hm.inputs.nixpkgs.legacyPackages.${system};

        modules = [
            ./users/paddy/home.nix
          ];

       extraSpecialArgs = { inherit hyprParams; };
      };

      mkHost = { pkgs, configPath, hm} : pkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({ ...}: { 
            _module.args.flakePath = self.outPath;
            _module.args.homeManagerPkg = hm.packages.${system}.home-manager;
          })
          configPath
        ];
      };
    in {
    nixosConfigurations = {
      pj-laptop = mkHost { 
          pkgs = nixpkgs-unstable; 
          configPath = ./hosts/pj-laptop/configuration.nix;
          hm = home-manager-unstable;
        };
      pj-desktop = mkHost { 
          pkgs = nixpkgs-25-05;
          configPath = ./hosts/pj-desktop/configuration.nix;
          hm = home-manager-25-05;
        };
   };
    homeConfigurations = {
      "paddy@pj-laptop" = mkHome {
          hm = home-manager-unstable; 
          hyprParams = {
            displayType = "laptop"; 
          };
        };
      "paddy@pj-desktop" = mkHome { 
          hm = home-manager-25-05;
          hyprParams = {
            displayType = "ultrawide"; 
          };
        };
    };
  };
}
