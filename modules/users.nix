{ pkgs, ...}:

{


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.paddy = {
    isNormalUser = true;
    description = "Paddy";
    extraGroups = [ "networkmanager" "wheel" "docker" "video"];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # udev rule to set the backlight node group and mode
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video %S%p/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w %S%p/brightness"
  '';
}
