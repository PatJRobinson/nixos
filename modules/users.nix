{...}: {
  users.users.paddy = {
    isNormalUser = true;
    description = "Paddy";
    extraGroups = ["networkmanager" "wheel" "docker" "video"];
  };

  # recovery user
  users.users.nixos = {
    isNormalUser = true;
    description = "nixos";
    extraGroups = ["networkmanager" "wheel" "docker" "video"];
  };
  nix.settings.trusted-users = ["root" "paddy" "nixos"];
}
