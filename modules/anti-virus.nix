{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    clamav
  ];

  services.clamav.updater.enable = true;
}
