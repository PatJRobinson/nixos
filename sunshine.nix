{ pkgs, ...}:

{

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  systemd.user.services.sunshine = {
    enable = true;
    wantedBy = [  "default.target"
                  "graphical-session.target" ];
  };
}
