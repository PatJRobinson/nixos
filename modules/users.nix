{...}: {
  users.users.paddy = {
    isNormalUser = true;
    description = "Paddy";
    extraGroups = ["networkmanager" "wheel" "docker" "video"];
  };
  nix.settings.trusted-users = ["root" "paddy"];
}
