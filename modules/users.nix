{
  userName,
  pkgs,
  ...
}: {
  users.users.${userName} = {
    isNormalUser = true;
    description = "Main user";
    extraGroups = ["networkmanager" "wheel" "docker" "video"];
    shell = pkgs.zsh;
  };

  # recovery user
  users.users.nixos = {
    isNormalUser = true;
    description = "nixos";
    extraGroups = ["networkmanager" "wheel" "docker" "video"];
  };
  nix.settings.trusted-users = ["root" "${userName}" "nixos"];
}
