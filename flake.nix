{
  description = "My System Configuration";

  inputs = {
    nixpkgs-25-05.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-25-11.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager-25-05.url = "github:nix-community/home-manager/release-25.05";
    home-manager-25-05.inputs.nixpkgs.follows = "nixpkgs-25-05";
    home-manager-25-11.url = "github:nix-community/home-manager/release-25.11";
    home-manager-25-11.inputs.nixpkgs.follows = "nixpkgs-25-11";
  };

  outputs = {
    self,
    nixpkgs-25-11,
    nixpkgs-25-05,
    home-manager-25-11,
    home-manager-25-05,
  }: let
    system = "x86_64-linux";

    # drivers for audio on my desktop appears to work better on latest stable channel
    desktop = {
      hm = home-manager-25-05;
      pkgs = nixpkgs-25-05;
      channel = "25.05";
    };

    laptop = {
      hm = home-manager-25-11;
      pkgs = nixpkgs-25-11;
      channel = "25-11";
    };

    mkHome = {
      hm,
      userName,
      hyprParams,
      channel,
    }:
      hm.lib.homeManagerConfiguration {
        pkgs = hm.inputs.nixpkgs.legacyPackages.${system};

        modules = [
          ./users/paddy/home.nix
        ];

        extraSpecialArgs = {inherit channel hyprParams userName;};
      };

    mkHost = {
      pkgs,
      configPath,
      hm,
    }:
      pkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({...}: {
            _module.args.flakePath = self.outPath;
            _module.args.homeManagerPkg = hm.packages.${system}.home-manager;
          })
          configPath
        ];
      };
  in {
    nixosConfigurations = {
      pj-laptop = mkHost {
        pkgs = laptop.pkgs;
        configPath = ./hosts/pj-laptop/configuration.nix;
        hm = laptop.hm;
      };
      pj-desktop = mkHost {
        pkgs = desktop.pkgs;
        configPath = ./hosts/pj-desktop/configuration.nix;
        hm = desktop.hm;
      };
      work-laptop = mkHost {
        pkgs = laptop.pkgs;
        configPath = ./hosts/work-laptop/configuration.nix;
        hm = laptop.hm;
      };
    };
    homeConfigurations = {
      "paddy@pj-laptop" = mkHome {
        hm = laptop.hm;
        userName = "paddy";
        hyprParams = {
          displayType = "dual";
        };
        channel = laptop.channel;
      };
      "paddy@pj-desktop" = mkHome {
        hm = desktop.hm;
        userName = "paddy";
        hyprParams = {
          displayType = "ultrawide";
        };
        channel = desktop.channel;
      };
      "patrick@work-laptop" = mkHome {
        hm = laptop.hm;
        userName = "patrick";
        hyprParams = {
          displayType = "laptop";
        };
        channel = laptop.channel;
      };
    };
  };
}
