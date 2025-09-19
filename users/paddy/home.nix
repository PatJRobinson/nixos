{ config, pkgs, ... }:

let 
    waybarRepo = pkgs.fetchFromGitHub {
      owner = "PatJRobinson";
      repo = "WaybarTheme";
      rev = "/refs/tags/v1.0.0";
      sha256 = "1xy3zbvxk3qqa2h1l2qwfhwhmvm4ri2d3b7bhr0qi4wxim299mz7";
    };
in
{
  # Basic info
  home.username = "paddy";
  home.homeDirectory = "/home/paddy";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # Enable common programs
  programs.zsh = {
    enable = true;

    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
        { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; } # Installations with additional options. For the list of options, please refer to Zplug README.
      ];
    };

    oh-my-zsh = { # "ohMyZsh" without Home Manager
      enable = true;
      theme = "powerlevel10k/powerlevel10k";
    };
 };

  programs.git.enable = true;

  programs.kitty = {
    enable = true;

    extraConfig = ''
      include ${./Misterioso.conf}
    '';
  };

  # Example environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    PAGER  = "less";
  };

  # Packages to install
  home.packages = with pkgs; [
    neovim
    htop
    wget
    curl
    waybar
  ];

  home.file.".config/waybar".source = waybarRepo;
}

