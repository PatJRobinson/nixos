{
  description = "My System Configuration";

  inputs = {
    nixpkgs-25-11.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager-25-11.url = "github:nix-community/home-manager/release-25.11";
    home-manager-25-11.inputs.nixpkgs.follows = "nixpkgs-25-11";

    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager-unstable.url = "github:nix-community/home-manager";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs-25-11,
    home-manager-25-11,
    nixpkgs-unstable,
    home-manager-unstable,
  }: let
    system = "x86_64-linux";

    mkHostCfg = channel: {
      inherit channel;
      hm =
        if channel == "25.11"
        then home-manager-25-11
        else if channel == "unstable"
        then home-manager-unstable
        else null;
      pkgs =
        if channel == "25.11"
        then nixpkgs-25-11
        else if channel == "unstable"
        then nixpkgs-unstable
        else null;
    };

    desktop = mkHostCfg "25.11";
    laptop = mkHostCfg "25.11";
    # according to Jovian docs, has to be unstable
    deck = mkHostCfg "unstable";

    mkHome = {
      hm,
      pkgs,
      userName,
      hostParams,
      channel,
    }: let
      pkgs' = pkgs.legacyPackages.${system};
    in
      hm.lib.homeManagerConfiguration {
        pkgs = pkgs';

        modules = [
          ./users/paddy/home.nix
        ];

        extraSpecialArgs = {
          inherit channel hostParams userName;
          pkgs = pkgs';
        };
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
      deck = mkHost {
        pkgs = deck.pkgs;
        configPath = ./hosts/deck/configuration.nix;
        hm = deck.hm;
      };
    };
    homeConfigurations = {
      "paddy@pj-laptop" = mkHome {
        hm = laptop.hm;
        pkgs = laptop.pkgs;
        userName = "paddy";
        hostParams = {
          name = "pj-laptop";
          wm = {
            type = "hypr";
            displayParams = {
              displayType = "dual";
            };
          };
        };
        channel = laptop.channel;
      };
      "paddy@pj-desktop" = mkHome {
        hm = desktop.hm;
        pkgs = desktop.pkgs;
        userName = "paddy";
        hostParams = {
          name = "pj-desktop";
          wm = {
            type = "hypr";
            displayParams = {
              displayType = "ultrawide";
            };
          };
        };
        channel = desktop.channel;
      };
      "paddy@work-laptop" = mkHome {
        hm = laptop.hm;
        pkgs = laptop.pkgs;
        userName = "paddy";
        hostParams = {
          name = "work-laptop";
          wm = {
            type = "hypr";
            displayParams = {
              displayType = "laptop";
            };
          };
        };
        channel = laptop.channel;
      };
      "paddy@deck" = mkHome {
        hm = deck.hm;
        pkgs = deck.pkgs;
        userName = "paddy";
        hostParams = {
          name = "deck";
          wm = {
            type = "gnome";
            displayParams = {
              displayType = "deck";
            };
          };
        };
        channel = deck.channel;
      };
    };
  };
}
