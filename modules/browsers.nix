{pkgs, ...}:

let

  braveWayland = pkgs.writeShellScriptBin "brave-wayland" ''
    exec ${pkgs.brave}/bin/brave \
      --enable-features=UseOzonePlatform \
      --ozone-platform=wayland \
      "$@"
  '';

 in
{

  environment.systemPackages = with pkgs; [
    brave
    braveWayland
    qutebrowser
  ];


  programs.firejail = {
    enable = true;
    wrappedBinaries = {

      brave-google = {
        executable = "${braveWayland}/bin/brave-wayland";
        profile = "${pkgs.firejail}/etc/firejail/brave.profile";
        extraArgs = [
          "--private=~/.local/firejail/brave-google"
          # Required for U2F USB stick
          "--ignore=private-dev"
          # Enforce dark mode
          "--env=GTK_THEME=Adwaita:dark"
          # Enable system notifications
          "--dbus-user.talk=org.freedesktop.Notifications"
        ];
      };

      brave-chatgpt = {
        executable = "${braveWayland}/bin/brave-wayland";
        profile = "${pkgs.firejail}/etc/firejail/brave.profile";
        extraArgs = [
          "--private=~/.local/firejail/brave-chatgpt"
          # Required for U2F USB stick
          "--ignore=private-dev"
          # Enforce dark mode
          "--env=GTK_THEME=Adwaita:dark"
          # Enable system notifications
          "--dbus-user.talk=org.freedesktop.Notifications"
        ];
      };

      brave-casual = {
        executable = "${braveWayland}/bin/brave-wayland";
        profile = "${pkgs.firejail}/etc/firejail/brave.profile";
        extraArgs = [
          "--private=~/.local/firejail/brave-casual"
          # Required for U2F USB stick
          "--ignore=private-dev"
          # Enforce dark mode
          "--env=GTK_THEME=Adwaita:dark"
          # Enable system notifications
          "--dbus-user.talk=org.freedesktop.Notifications"
        ];
      };

      qute-chatgpt = {
        executable = "${pkgs.qutebrowser}/bin/qutebrowser";
        profile = "${pkgs.firejail}/etc/firejail/qutebrowser.profile";
        extraArgs = [
          "--private=~/.local/firejail/qute-chatgpt"
          "--env=QUTE_NOIPC=1"
          "--dbus-user.talk=org.freedesktop.Notifications"         
       ];
      };

      qute-casual = {
        executable = "${pkgs.qutebrowser}/bin/qutebrowser";
        profile = "${pkgs.firejail}/etc/firejail/qutebrowser.profile";
        extraArgs = [
          "--private=~/.local/firejail/qute-casual"
          "--env=QUTE_NOIPC=1"
          "--dbus-user.talk=org.freedesktop.Notifications"         
        ];
      };

     };
  };
}
