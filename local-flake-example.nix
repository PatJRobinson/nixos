{
  description = "Local system configuration";

  inputs = {
    config-builder.url = "path:/home/user/nixos/nixos-config-generator";
  };

  outputs = {
    self,
    config-builder,
  }: let
    hostName = "host"; # what to call the machine
    userName = "user"; # what to call the user

    # the system-generated file for your system
    hardwareConfigurationFile = "/path/to/hardware-configuration.nix";

    # create config parameters
    hostCfg = config-builder.lib.mkHostCfg {
      inherit hostName hardwareConfigurationFile;
      channel = "25.11";
      flakePath = self.outPath;
      defaultUserName = userName;
      gpuSupport = "nvidia"; # or 'amd' or 'intel'
      hostParams = {
        name = hostName;
        wm = {
          type = "hypr";
          displayParams = {
            displayType = "ultrawide";
          };
        };
      };

      # firewall configuration (becomes `networking.firewall')
      # https://nixos.wiki/wiki/Firewall
      firewallCfg = {
        enable = true;
      };
    };
    # put ssh config here
    # https://mynixos.com/home-manager/option/programs.ssh.matchBlocks
    sshCfg = {};

    # ends up as 'programs.git'
    # https://nixos.wiki/wiki/Git
    gitCfg = {};

    # any additional env vars
    envVars = {};
  in {
    nixosConfigurations.${hostName} = config-builder.lib.mkHost {
      inherit hostCfg;
    };

    homeConfigurations."${userName}@${hostName}" = config-builder.lib.mkHome {
      inherit hostCfg userName sshCfg gitCfg envVars;
    };
  };
}
