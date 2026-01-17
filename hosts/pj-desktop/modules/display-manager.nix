{pkgs, ...}: {
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome.enable = false;
  services.xserver.displayManager.gdm = {
    enable = true;
    autoSuspend = false;
  };

  services.logind.extraConfig = ''
    IdleAction=ignore
    IdleActionSec=0
  '';
}
