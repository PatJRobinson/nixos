{userName, ...}: {
  users.users.${userName} = {
    isNormalUser = true;
    description = "Main user";
    extraGroups = ["networkmanager" "wheel" "docker" "video"];
  };

  # recovery user
  users.users.nixos = {
    isNormalUser = true;
    description = "nixos";
    extraGroups = ["networkmanager" "wheel" "docker" "video"];
  };
  nix.settings.trusted-users = ["root" "${userName}" "nixos"];
}
