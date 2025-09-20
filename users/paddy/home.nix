{ config, pkgs, display_type, ... }:

let 

    hyprRepo = if display_type == "laptop" then
      pkgs.fetchFromGitHub {
        owner = "PatJRobinson";
        repo = "hyprland-dotfiles";
        rev = "/refs/tags/v1.0.1-laptop";
        sha256 = "1924ksi4fmw0x3pa0q6cb1pj2gvvmlrai9sffi45ysypc8ij66yx";
      }
      else if display_type == "ultrawide" then
      pkgs.fetchFromGitHub {
        owner = "PatJRobinson";
        repo = "hyprland-dotfiles";
        rev = "/refs/tags/v1.0.1-ultrawide";
        sha256 = "1dzpyznyyai9aa1ddzy96nxxd7vx51b7m7hzwgl1631gr9llkb0c";
      }
      else {};

    waybarRepo = pkgs.fetchFromGitHub {
      owner = "PatJRobinson";
      repo = "WaybarTheme";
      rev = "/refs/tags/v1.0.0";
      sha256 = "1xy3zbvxk3qqa2h1l2qwfhwhmvm4ri2d3b7bhr0qi4wxim299mz7";
    };

    neovimRepo = pkgs.fetchFromGitHub {
      owner = "PatJRobinson";
      repo = "kickstart.nvim";
      rev = "/refs/tags/v1.0.0";
      sha256 = "1hw6ls68vyq5vnz36gcqq61ipzwwnwa00aic8jx7vaxb2jp0qg2w";
    };

in
{
  # Basic info
  home.username = "paddy";
  home.homeDirectory = "/home/paddy";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # Enable common programs
  programs.zsh = {
    enable = true;

    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
        {
          name = "romkatv/powerlevel10k"; 
          tags = [ as:theme depth:1 ]; 
        } # Installations with additional options. For the list of options, please refer to Zplug README.
      ];
    };

    oh-my-zsh = { # "ohMyZsh" without Home Manager
      enable = true;
    };

    initContent = ''
      [[ ! -f ${./p10k-config/.p10k.zsh} ]] || source ${./p10k-config/.p10k.zsh}
    '';
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
  home.file.".config/hypr".source = hyprRepo;
  home.file.".config/nvim".source = neovimRepo;
  home.file."wallpapers".source = ./wallpapers;
}

