{
  userName,
  pkgs,
  ...
}: {
  # default shell set at the system level, package needs to be
  # available
  programs.zsh.enable = true;

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
