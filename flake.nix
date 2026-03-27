{
  description = "Nixos system configuration builder";

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
  in {
    lib = {
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

      mkHome = {
        hm,
        pkgs,
        userName,
        hostParams,
        channel,
        sshCfg ? {enable = false;},
      }: let
        pkgs' = pkgs.legacyPackages.${system};
      in
        hm.lib.homeManagerConfiguration {
          pkgs = pkgs';

          modules = [
            ./users/paddy/home.nix
          ];

          extraSpecialArgs = {
            inherit channel hostParams userName sshCfg;
            pkgs = pkgs';
          };
        };

      mkHost = {
        hostName,
        pkgs,
        hm,
        flakePath,
        gpuSupport ? null, # "nvidia | "amd" | "intel" | null
        extraModules ? [],
      }:
        pkgs.lib.nixosSystem {
          inherit system;
          modules =
            [
              ({...}: {
                _module.args.hostName = hostName;
                _module.args.flakePath = flakePath;
                _module.args.homeManagerPkg = hm.packages.${system}.home-manager;
              })
              ./hosts/base-configuration.nix
              (flakePath + "/hardware-configuration.nix")
            ]
            ++ pkgs.lib.optionals (gpuSupport == "nvidia") [./modules/nvidia-graphics.nix]
            #++ pkgs.lib.optionals (gpuSupport == "amd") [ ./modules/amd.nix ]
            ++ pkgs.lib.optionals (gpuSupport == "intel") [./modules/intel-graphics.nix]
            ++ extraModules;
        };
    };
  };
}
