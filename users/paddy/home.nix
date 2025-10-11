{ config, pkgs, userName, hyprParams, ... }:

let 

    neovimRepo = pkgs.fetchFromGitHub {
      owner = "PatJRobinson";
      repo = "kickstart.nvim";
      rev = "/refs/tags/v1.0.0";
      sha256 = "1hw6ls68vyq5vnz36gcqq61ipzwwnwa00aic8jx7vaxb2jp0qg2w";
    };

in
{
  # Basic info
  home.username = userName;
  home.homeDirectory = "/home/${userName}";
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

      pw() {
        if [[ $# -lt 1 ]]; then
          echo "Usage: bwcopy <item-name-or-id>"
          return 1
        fi

        bw get password "$@" | wl-copy
     }
     alias lsd="yazi"
    function y() {
      local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
      yazi "$@" --cwd-file="$tmp"
      if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
      fi
      rm -f -- "$tmp"
    }
    '';
  };

  programs.git.enable = true;

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set-option -g default-shell "${pkgs.zsh}/bin/zsh"
      set-option -g default-command "${pkgs.zsh}/bin/zsh -l"
      set-option -g default-terminal "tmux-256color"
    '';
  };

  programs.yazi.enable = true;

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
    qutebrowser
    bitwarden-desktop
    bitwarden-cli
    ranger
  ];

  imports = [
    (import ./modules/hyprland.nix { inherit hyprParams; } )
    (import ./modules/visualisation.nix )
  ];

  home.file.".config/nvim".source = neovimRepo;

  services.hyprpaper.enable = true;
  # script in ~/.config/hypr/scripts to select random wallpaper
  home.file."wallpapers".source = ./wallpapers;
  home.file.".config/rofi".source = ./rofi;

  programs.ghostty.enable = true;
  programs.kitty.enable = true;
  home.file.".config/kitty".source = ./kitty;
  # set gruvbox theme
  home.file.".config/ghostty".source = ./ghostty;

  programs.waybar.enable = true;
  # src: https://github.com/poetaste/dotfiles.git
  home.file.".config/waybar".source = ./waybar;
}

