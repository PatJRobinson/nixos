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
      mkHostCfg = {
        hostName,
        hardwareConfigurationFile,
        channel,
        flakePath,
        defaultUserName,
        gpuSupport ? null, # "nvidia | "amd" | "intel" | null
        hostParams,
        firewallCfg ? {},
        extraModules ? [],
        enableDocker ? true,
      }: {
        inherit hostName hardwareConfigurationFile channel flakePath defaultUserName gpuSupport hostParams firewallCfg extraModules enableDocker;
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

      mkHost = {hostCfg}:
        with hostCfg;
          pkgs.lib.nixosSystem {
            inherit system;
            modules =
              [
                ({...}: {
                  _module.args.hostName = hostName;
                  _module.args.userName = defaultUserName;
                  _module.args.flakePath = flakePath;
                  _module.args.homeManagerPkg = hm.packages.${system}.home-manager;
                  _module.args.firewallCfg = firewallCfg;
                  _module.args.enableDocker = enableDocker;
                })
                ./host/base-configuration.nix
                hardwareConfigurationFile
              ]
              ++ pkgs.lib.optionals (gpuSupport == "nvidia") [./modules/nvidia-graphics.nix]
              #++ pkgs.lib.optionals (gpuSupport == "amd") [ ./modules/amd.nix ]
              ++ pkgs.lib.optionals (gpuSupport == "intel") [./modules/intel-graphics.nix]
              ++ extraModules;
          };

      mkHome = {
        hostCfg,
        userName,
        gitCfg ? {enable = false;},
        sshCfg ? {enable = false;},
        envVars ? {},
      }:
        with hostCfg; let
          pkgs' = pkgs.legacyPackages.${system};
        in
          hm.lib.homeManagerConfiguration {
            pkgs = pkgs';

            modules = [
              ./user/home.nix
            ];

            extraSpecialArgs = {
              inherit channel hostParams userName sshCfg gitCfg envVars;
              pkgs = pkgs';
            };
          };
    };
  };
}
