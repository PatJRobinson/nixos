{lib, pkgs, ...}: {
  # Interactive Bash setup; retain the original Zsh configuration as a fallback.
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historySize = 10000;
    historyFileSize = 10000;
    historyControl = ["ignoredups" "ignorespace"];
    bashrcExtra = ''
      if [[ $- == *i* && $TERM != dumb && -t 0 && -t 1 ]]; then
        source ${pkgs.blesh}/share/blesh/ble.sh --attach=none
      fi
    '';
    initExtra = lib.mkMerge [
      ''
        source ${../shell/functions.sh}
        import-zsh-history() {
          # Flush this session before the importer merges history files.
          history -a
          PATH="${lib.makeBinPath [pkgs.zsh]}:$PATH" \
            ${pkgs.python3}/bin/python3 ${../shell/import-zsh-history.py} \
            "''${1:-$HOME/.zsh_history}" "''${HISTFILE:-$HOME/.bash_history}" || return
          history -c
          history -r
        }
        _bash_trial_history_sync() {
          history -a
          history -n
        }
        PROMPT_COMMAND+=(_bash_trial_history_sync)
        if [[ -n ''${GHOSTTY_RESOURCES_DIR:-} ]]; then
          source "$GHOSTTY_RESOURCES_DIR/shell-integration/bash/ghostty.bash"
        fi
      ''
      (lib.mkOrder 2000 ''
        if [[ -n ''${BLE_VERSION:-} ]]; then
          ble-attach
        fi
      '')
    ];
  };

  xdg.configFile."blesh/init.sh".text = ''
    bleopt complete_auto_complete=1
    bleopt complete_auto_history=1
    ble-face -s auto_complete fg=242
    bleopt prompt_ps1_transient=always
    bleopt prompt_ps1_final='$(starship module character)'
    bleopt prompt_rps1_final=
  '';

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = false;
    enableFishIntegration = false;
    settings = {
      # Match the custom p10k theme: transparent, compact, no powerline blocks.
      add_newline = false;
      format = "$os$directory$git_branch$git_status$character";
      right_format = "$status$cmd_duration$jobs$direnv$python$nodejs$terraform$kubernetes$aws$azure$gcloud$nix_shell$time";
      os = {
        disabled = false;
        format = "[$symbol]($style) ";
        style = "none";
        symbols.NixOS = "";
      };
      directory = {
        style = "250";
        truncation_length = 4;
        truncate_to_repo = false;
        read_only = " ";
        format = "[$path]($style)[$read_only]($read_only_style) ";
      };
      character = {
        success_symbol = "[❯](106)";
        error_symbol = "[❯](196)";
        vimcmd_symbol = "[❮](106)";
      };
      git_branch = {
        symbol = " ";
        style = "106";
        format = "[$symbol$branch(:$remote_branch)]($style) ";
      };
      git_status = {
        style = "106";
        format = "([$all_status$ahead_behind]($style) )";
        conflicted = "~\${count}";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇣\${behind_count}⇡\${ahead_count}";
        untracked = "?\${count}";
        stashed = "*\${count}";
        modified = "!\${count}";
        staged = "+\${count}";
      };
      status = {disabled = false; style = "160"; format = "[$symbol$status]($style) ";};
      cmd_duration = {min_time = 3000; style = "101"; format = "[$duration]($style) ";};
      jobs = {style = "37"; format = "[$symbol$number]($style) ";};
      direnv.disabled = false;
      python.format = "[$symbol$virtualenv]($style) ";
      kubernetes.disabled = false;
      nix_shell = {format = "[$symbol$state]($style) "; style = "74";};
      time = {disabled = false; time_format = "%T"; style = "66"; format = "[$time]($style)";};
    };
  };
}
