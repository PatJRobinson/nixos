{pkgs, ...}: {
  # brightness is a sysfs attribute, so set its permissions explicitly.
  # users.nix grants the desktop users membership of the video group.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys%p/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys%p/brightness"
  '';
}
