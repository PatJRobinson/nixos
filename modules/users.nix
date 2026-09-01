{
  userName,
  pkgs,
  ...
}: {
  # default shell set at the system level, package needs to be
  # available
  programs.zsh.enable = true;

  users.groups.library = {};

  users.users.${userName} = {
    isNormalUser = true;
    description = "Main user";
    extraGroups = ["networkmanager" "wheel" "docker" "video" "library"];
    shell = pkgs.zsh;
  };

  users.users.kavita.extraGroups = ["library"];

  # recovery user
  users.users.nixos = {
    isNormalUser = true;
    description = "nixos";
    extraGroups = ["networkmanager" "wheel" "docker" "video"];
  };
  nix.settings.trusted-users = ["root" "${userName}" "nixos"];
}
