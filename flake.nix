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

  outputs = {
    self,
    nixpkgs-unstable,
    nixpkgs-25-05,
    home-manager-unstable,
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
      hm = home-manager-unstable;
      pkgs = nixpkgs-unstable;
      channel = "unstable";
    };

    deck = {
      hm = home-manager-unstable;
      pkgs = nixpkgs-unstable;
      channel = "unstable";
    };

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
              displayType = "dual-4k";
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
      "patrick@work-laptop" = mkHome {
        hm = laptop.hm;
        pkgs = laptop.pkgs;
        userName = "patrick";
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
