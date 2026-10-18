{lib, pkgs, ...}: let
  bashAutosuggestions = pkgs.callPackage ./bash-autosuggestions.nix {};
in {
  # Patch both the installed bindings and those embedded in `fzf --bash`.
  programs.fzf.package = pkgs.fzf.overrideAttrs (old: {
    patches = (old.patches or []) ++ [../shell/fzf-bash-history-number.patch];
  });

  # Interactive Bash setup; retain the original Zsh configuration as a fallback.
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historySize = 10000;
    historyFileSize = 10000;
    historyControl = ["erasedups" "ignorespace"];
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
        # Fuzzy path completion on Tab without requiring the ** suffix.
        FZF_COMPLETION_TRIGGER=""
        FZF_COMPLETION_OPTS="''${FZF_COMPLETION_OPTS:+$FZF_COMPLETION_OPTS }--select-1"
      ''
      (lib.mkOrder 2000 ''
        if [[ $- == *i* && $TERM != dumb && -t 0 && -t 1 ]]; then
          BASH_AUTOSUGGEST_STRATEGY=history
          BASH_AUTOSUGGEST_USE_ASYNC=auto
          BASH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'
          if enable -f ${bashAutosuggestions}/lib/bash-autosuggestions.so bash_autosuggestions; then
            builtin bash_autosuggestions enable
          fi
        fi
        # Cycle through history entries matching the text before the cursor.
        bind '"\e[A": history-search-backward'
        bind '"\e[B": history-search-forward'
      '')
    ];
  };

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
