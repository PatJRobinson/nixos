{
  pkgs,
  channel,
  userName,
  hostParams,
  ...
}: let
  wm = hostParams.wm;

  darkMode = false;
  ghosttyTheme =
    if darkMode
    then "Dark"
    else "Light";

  neovimRepo = pkgs.fetchFromGitHub {
    owner = "PatJRobinson";
    repo = "kickstart.nvim";
    rev = "/refs/heads/master";
    sha256 = "sha256-iDJTAiDc0/EN+P43DytvYQMmEUieL8mW3Nqos+j/TZ4=";
  };

  wallpapers_dir =
    if wm.displayParams.displayType == "ultrawide"
    then
      if darkMode
      then ./wallpapers-ultrawide-dark
      else ./wallpapers-ultrawide-light
    else if darkMode
    then ./wallpapers-dark
    else ./wallpapers-light;
in {
  home = {
    username = userName;
    homeDirectory = "/home/${userName}";
    stateVersion = "25.05";

    # Example environment variables
    sessionVariables = {
      EDITOR = "nvim";
      PAGER = "less";
      NVIM_DARK_MODE =
        if darkMode
        then "1"
        else "0";
    };

    # Packages to install
    packages = with pkgs; [
      mesa-demos
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
  };

  systemd.user.services.set-random-wallpaper = {
    Unit = {
      Description = "Set random wallpaper (after hyprpaper)";
      After = ["hyprpaper.service"];
      Wants = ["hyprpaper.service"];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -lc 'systemctl --user start hyprpaper.service; systemctl --user is-active --quiet hyprpaper.service; %h/.local/bin/set-random-wallpaper.sh'";
    };
  };

  systemd.user.services.pipewire = {
    Unit = {Description = "PipeWire Multimedia Service";};
    Service = {
      ExecStart = "${pkgs.pipewire}/bin/pipewire";
      Restart = "on-failure";
    };
    Install = {WantedBy = ["default.target"];};
  };

  systemd.user.services.wireplumber = {
    Unit = {
      Description = "WirePlumber Session Manager";
      After = ["pipewire.service"];
    };
    Service = {
      ExecStart = "${pkgs.wireplumber}/bin/wireplumber";
      Restart = "on-failure";
    };
    Install = {WantedBy = ["default.target"];};
  };

  systemd.user.services.pipewire-pulse = {
    Unit = {
      Description = "PipeWire PulseAudio";
      After = ["pipewire.service"];
    };
    Service = {
      ExecStart = "${pkgs.pipewire}/bin/pipewire-pulse";
      Restart = "on-failure";
    };
    Install = {WantedBy = ["default.target"];};
  };

  home.file =
    {
      "wallpapers/".source = wallpapers_dir;
      ".local/bin/set-random-wallpaper.sh".source = ./hyprland-scripts/set-random-wallpaper.sh;

      ".p10k.zsh".source = ./p10k-config/.p10k.zsh;

      # set gruvbox theme
      ".config/ghostty/config".text = ''
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

      ".config/nvim".source = neovimRepo;
      ".local/firejail/qute-casual/.config/qutebrowser/config.py" = {
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
    // pkgs.lib.optionalAttrs (wm.type == "hypr") {
      ".config/rofi".source = ./rofi;
      # src: https://github.com/poetaste/dotfiles.git
      ".config/waybar/config".source = ./waybar/config;
      ".config/waybar/style.css".source =
        if darkMode
        then ./waybar/style-dark.css
        else ./waybar/style-light.css;
      ".config/waybar/scripts".source = ./waybar/scripts;
    };

  programs =
    {
      home-manager.enable = true;
      foot.enable = true;
      ghostty.enable = true;
      ripgrep.enable = true;
      lsd.enable = true;
      bat.enable = true;
      fzf.enable = true;
      git.enable = true;
      yazi.enable = true;

      direnv.enable = true;
      zathura.enable = true;

      zsh = {
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

      neovim = {
        enable = true;
        plugins = with pkgs.vimPlugins; [
          focus-nvim
        ];
      };
      tmux = {
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
      ssh =
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
              HostName 192.168.2.10
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
              hostname = "192.168.2.10";
              user = "patri";
              identityFile = "~/.ssh/id_rsa";
              identitiesOnly = true;
              setEnv = {
                TERM = "xterm-256color";
              };
            };
            "buildserver" = {
              hostname = "192.168.2.10";
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
    }
    // pkgs.lib.optionalAttrs (wm.type == "hypr") {
      waybar = {
        enable = true;
        systemd.enable = false;
      };
    };

  imports =
    [
      ./modules/desktop-shortcuts.nix
    ]
    ++ pkgs.lib.optionals (wm.type == "hypr") [
      (import ./modules/hyprland.nix {displayParams = wm.displayParams;})
      (import ./modules/visualisation.nix)
    ];

  services =
    if (wm.type == "hypr")
    then {
      hyprpaper.enable = true;
      hyprsunset.enable = true;
    }
    else {};
}
