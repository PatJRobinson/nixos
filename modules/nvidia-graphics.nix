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
    open = true; # CDI generation issue with proprietry driver 580.142, needs looking into
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
