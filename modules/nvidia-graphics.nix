{...}: {
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
  ];
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia.open = true; # or false if you're intentionally using proprietary
  hardware.nvidia.modesetting.enable = true;

  # isable HDA power saving at the kernel driver level - help with audio hiss on boot
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0 power_save_controller=N
  '';
}
