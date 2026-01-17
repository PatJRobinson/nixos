{
  pkgs,
  channel,
  userName,
  hyprParams,
  ...
}: let
  darkMode = false;
  ghosttyTheme =
    if darkMode
    then "Dark"
    else "Light";

  neovimRepo = pkgs.fetchFromGitHub {
    owner = "PatJRobinson";
    repo = "kickstart.nvim";
    rev = "/refs/heads/master";
    sha256 = "sha256-3MojV+3I1PYSqAKslTegLyJNgKo4qm2aJ4w5YUu69Ms=";
  };

  wallpapers_dir =
    if hyprParams.displayType == "ultrawide"
    then
      if darkMode
      then ./wallpapers-ultrawide-dark
      else ./wallpapers-ultrawide-light
    else if darkMode
    then ./wallpapers-dark
    else ./wallpapers-light;
in {
  # Basic info
  home.username = userName;
  home.homeDirectory = "/home/${userName}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # Enable common programs
  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      # "ohMyZsh" without Home Manager
      enable = true;
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

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

      rcp() {
        rsync -avh --progress "$@"
      }
    '';
  };

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      focus-nvim
    ];
  };

  programs.ripgrep.enable = true;
  programs.lsd.enable = true;
  programs.bat.enable = true;
  programs.fzf.enable = true;
  programs.git.enable = true;
  programs.yazi.enable = true;

  programs.direnv.enable = true;
  programs.zathura.enable = true;

  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    historyLimit = 100000;
    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
    ];
    extraConfig = ''
    '';
  };

  # Example environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    PAGER = "less";
  };

  # Packages to install
  home.packages = with pkgs; [
    zsh-powerlevel10k
    fastfetch
    htop
    wget
    curl
    rsync
    qutebrowser
    bitwarden-desktop
    bitwarden-cli
    libnotify
    nix-direnv
    lua-language-server
    yaml-language-server
    nil
    marksman
    (flameshot.override {enableWlrSupport = true;})
    alejandra
    bluetuith
    gdu
    (import ./modules/rust-packages/keifu.nix {inherit pkgs;})
  ];

  imports = [
    (import ./modules/hyprland.nix {inherit hyprParams;})
    (import ./modules/visualisation.nix)
  ];

  programs.ssh =
    if channel == "25.05"
    then {
      enable = true;

      # Only options valid for the old version
      extraConfig = ''
        Host gitlab.com
          HostName gitlab.com
          User git
          IdentityFile ~/.ssh/id_rsa
          IdentitiesOnly yes

        Host patri
          HostName 192.168.2.192
          User patri
          IdentityFile ~/.ssh/id_rsa
          IdentitiesOnly yes
          SetEnv TERM=xterm-256color
      '';
    }
    else {
      enable = true;

      # Disable legacy defaults (new HM versions)
      enableDefaultConfig = false;

      matchBlocks = {
        "gitlab.com" = {
          host = "gitlab.com"; # or "hostname"
          hostname = "gitlab.com";
          user = "git";
          identityFile = "~/.ssh/id_rsa";
          identitiesOnly = true;
        };
        "patri" = {
          hostname = "192.168.2.192";
          user = "patri";
          identityFile = "~/.ssh/id_rsa";
          identitiesOnly = true;
          setEnv = {
            TERM = "xterm-256color";
          };
        };
        "buildserver" = {
          hostname = "192.168.2.192";
          user = "calyo";
          identityFile = "~/.ssh/id_rsa";
          identitiesOnly = true;
          setEnv = {
            TERM = "xterm-256color";
          };
        };
        "paddy" = {
          hostname = "192.168.0.18";
          user = "paddy";
          identityFile = "~/.ssh/id_rsa";
          identitiesOnly = true;
        };
      };
    };

  services.hyprpaper.enable = true;
  services.hyprsunset.enable = true;
  programs.waybar.enable = true;
  programs.ghostty.enable = true;

  home.sessionVariables = {
    NVIM_DARK_MODE =
      if darkMode
      then "1"
      else "0";
  };

  home.file."wallpapers".source = "${wallpapers_dir}";
  home.file.".config/rofi".source = ./rofi;

  home.file.".p10k.zsh".source = ./p10k-config/.p10k.zsh;

  home.file.".config/kitty".source = ./kitty;
  # set gruvbox theme
  home.file.".config/ghostty/config".text = ''
    ${
      if channel == "25.05"
      then ''
        theme = Gruvbox${ghosttyTheme}Hard
        app-notifications = no-clipboard-copy
        term=xterm-256color
      ''
      else ''
        theme = Gruvbox ${ghosttyTheme} Hard
        app-notifications = no-clipboard-copy
      ''
    }
  '';

  # src: https://github.com/poetaste/dotfiles.git
  home.file.".config/waybar/config".source = ./waybar/config;
  home.file.".config/waybar/style.css".source =
    if darkMode
    then ./waybar/style-dark.css
    else ./waybar/style-light.css;
  home.file.".config/waybar/scripts".source = ./waybar/scripts;

  home.file.".config/nvim".source = neovimRepo;
  home.file.".local/firejail/qute-casual/.config/qutebrowser/config.py" = {
    text =
      builtins.readFile (
        if darkMode
        then ./qutebrowser/colours-dark.py
        else ./qutebrowser/colours-light.py
      )
      + builtins.readFile ./qutebrowser/config.py
      + ''
        c.colors.webpage.darkmode.enabled = ${
          if darkMode
          then "True"
          else "False"
        }
        config.load_autoconfig(False)
      '';
  };
}
