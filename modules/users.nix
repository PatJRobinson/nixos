{...}: {
  users.users.paddy = {
    isNormalUser = true;
    description = "Paddy";
    extraGroups = ["networkmanager" "wheel" "docker"];
  };
  nix.settings.trusted-users = ["root" "paddy"];
}
