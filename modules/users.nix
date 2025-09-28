{ pkgs, ...}:

{


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.paddy = {
    isNormalUser = true;
    description = "Paddy";
    extraGroups = [ "networkmanager" "wheel" "docker"];
    packages = with pkgs; [
    #  thunderbird
    ];
  };
}
