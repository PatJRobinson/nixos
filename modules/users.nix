{ pkgs, ...}:

{

  users.users.paddy = {
    isNormalUser = true;
    description = "Paddy";
    extraGroups = [ "networkmanager" "wheel" "docker"];
    packages = with pkgs; [
    #  thunderbird
    ];
  };
  nix.settings.trusted-users = [ "root" "paddy" ];

}
