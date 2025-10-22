{ config, pkgs, userName, hyprParams, ... }:

let 

    neovimRepo = pkgs.fetchFromGitHub {
      owner = "PatJRobinson";
      repo = "kickstart.nvim";
      rev = "/refs/tags/v1.0.2";
      sha256 = "0ggbrlg1yn4raplw7rv216hq44lywzi3i854pb0f8xl073whq6cd";
    };

    wallpapers_dir = 
      if hyprParams.displayType == "ultrawide" then ./wallpapers-ultrawide else ./wallpapers;
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

    function f() {
      local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
      yazi "$@" --cwd-file="$tmp"
      if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
      fi
      rm -f -- "$tmp"
    }

    '';
  };

  programs.lsd.enable = true;
  programs.git.enable = true;
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
    libnotify
  ];

  imports = [
    (import ./modules/hyprland.nix { inherit hyprParams; } )
    (import ./modules/visualisation.nix )
  ];


  services.hyprpaper.enable = true;
  services.hyprsunset.enable = true;
  # script in ~/.config/hypr/scripts to select random wallpaper
  home.file."wallpapers".source = "${wallpapers_dir}";
  home.file.".config/rofi".source = ./rofi;

  home.file.".p10k.zsh".source = ./p10k-config/.p10k.zsh;

  programs.ghostty.enable = true;
  programs.kitty.enable = true;
  home.file.".config/kitty".source = ./kitty;
  # set gruvbox theme
  home.file.".config/ghostty".source = ./ghostty;

  programs.waybar.enable = true;
  # src: https://github.com/poetaste/dotfiles.git
  home.file.".config/waybar".source = ./waybar;

  home.file.".config/nvim".source = neovimRepo;
}

