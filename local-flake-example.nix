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

    # create config parameters
    hostCfg = config-builder.lib.mkHostCfg {
      inherit hostName;
      channel = "25.11";
      flakePath = self.outPath;
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
    };
    # put ssh config here
    # https://mynixos.com/home-manager/option/programs.ssh.matchBlocks
    sshCfg = {};

    # any additional env vars
    envVars = {};
  in {
    nixosConfigurations.hostname = config-builder.lib.mkHost {
      inherit hostCfg;
    };

    homeConfigurations."${userName}@${hostName}" = config-builder.lib.mkHome {
      inherit hostCfg userName sshCfg envVars;
    };
  };
}
