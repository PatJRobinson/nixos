{...}: {
  system.stateVersion = "25.05";
  imports = [
    ./hardware-configuration.nix
    ../../modules/home-manager.nix
    ../../modules/audio.nix
    ../../modules/caches.nix
    ../../modules/bootloader.nix
    ../../modules/time-zone.nix
    ../../modules/auto-upgrade.nix
    ../../modules/display-manager.nix
    ./modules/networking.nix
    ../../modules/firewall.nix
    ../../modules/sunshine.nix
    ../../modules/open-ssh.nix
    ../../modules/terminal.nix
    ../../modules/steam.nix
    ../../modules/hyprland.nix
    ../../modules/users.nix
    ../../modules/browsers.nix
    ../../modules/fonts.nix
    ../../modules/docker.nix
    ../../modules/text-editing.nix
    ../../modules/rust.nix
    ../../modules/cpp.nix
    ../../modules/moonlight.nix
    ../../modules/files.nix
    ../../modules/office.nix
    ../../modules/notifications.nix
    ../../modules/intel-graphics.nix
    ../../modules/monitoring.nix
    ../../modules/gc.nix
    ../../modules/firejail.nix
    ../../modules/filesystem.nix
    ../../modules/power.nix
    ../../modules/launchers.nix
  ];
  nix.settings.experimental-features = ["nix-command" "flakes"];
  hardware.graphics.enable = true;
  environment.sessionVariables.__EGL_VENDOR_LIBRARY_DIRS = "/run/opengl-driver/share/glvnd/egl_vendor.d/:/run/opengl-driver-32/share/glvnd/egl_vendor.d/";

  programs.ssh = {
    extraConfig = "
      Host gitlab.com
        HostName gitlab.com
        User git
        IdentityFile /etc/nix/gitlab_deploy_key
        IdentitiesOnly yes
    ";
  };
}
