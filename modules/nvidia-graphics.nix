{
  config,
  enableDocker,
  ...
}: {
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
  ];
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    open = true; # or false if you're intentionally using proprietary
    modesetting.enable = true;
    powerManagement.enable = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # docker
  hardware.nvidia-container-toolkit.enable =
    if enableDocker
    then true
    else false;
  virtualisation.docker.daemon.settings.features.cdi =
    if enableDocker
    then true
    else false;
}
