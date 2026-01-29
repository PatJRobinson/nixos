{...}: {
  services.power-profiles-daemon.enable = true;
  # If you use TLP/tuned/system76-power, disable the one you don't want:
  # services.tlp.enable = false;
}
