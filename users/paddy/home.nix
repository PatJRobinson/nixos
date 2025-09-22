{ config, pkgs, hyprParams, waybarParams, ... }:

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

      pw() {
        if [[ $# -lt 1 ]]; then
          echo "Usage: bwcopy <item-name-or-id>"
          return 1
        fi

        bw get password "$@" | wl-copy
     }
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
    qutebrowser
    bitwarden-desktop
    bitwarden-cli
    ranger
  ];

  services.hyprpaper.enable = true;

  imports = [
    (import ./modules/waybar.nix { inherit waybarParams; } )
    (import ./modules/hyprland.nix { inherit hyprParams; } )
  ];

  home.file.".config/nvim".source = neovimRepo;
  home.file."wallpapers".source = ./wallpapers;
  home.file.".config/rofi".source = ./rofi;
}

