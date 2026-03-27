{...}: {
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
  ];
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia.open = true; # or false if you're intentionally using proprietary
  hardware.nvidia.modesetting.enable = true;
}
