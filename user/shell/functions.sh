# Shared interactive helpers for Bash and Zsh.
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

# Smart Neovim launcher
function nv() {
  local mode=""
  local query=""
  local open_yazi=0
  local open_terminal=0

  # parse our custom flags
  while (( $# )); do
    case "$1" in
      -d|--dir)
        open_yazi=1
        shift
        ;;
      -t|--term)
        open_terminal=1
        shift
        ;;
      -f|--find)
        mode="find"
        shift
        if (( $# )) && [[ "$1" != -* ]]; then
          query="$1"
          shift
        fi
        ;;
      -g|--grep)
        mode="grep"
        shift
        if (( $# )) && [[ "$1" != -* ]]; then
          query="$1"
          shift
        fi
        ;;
      --)
        shift
        break
        ;;
      -*) # real nvim flags: stop parsing
        break
        ;;
      *)  # first non-flag arg
        break
        ;;
    esac
  done

  # remaining args go straight to nvim
  local -a args
  args=("$@")

  if [[ "$mode" == "find" ]]; then
    if [[ -n "$query" ]]; then
      args+=("+lua require('telescope.builtin').find_files({ default_text = [[$query]] })")
    else
      args+=("+lua require('telescope.builtin').find_files()")
    fi
  fi

  if [[ "$mode" == "grep" ]]; then
    if [[ -n "$query" ]]; then
      args+=("+lua require('telescope.builtin').live_grep({ default_text = [[$query]] })")
    else
      args+=("+lua require('telescope.builtin').live_grep()")
    fi
  fi

  if (( open_yazi )); then
    args+=("+Yazi")
  fi

  if (( open_terminal )); then
    args+=("+term")
  fi

  command nvim "${args[@]}"
}

rcp() {
  rsync -avh --progress "$@"
}

# wrapper for 'zotero add'
zadd() {
  local -a args
  args=("$@")
  command ~/.local/bin/zotero-add/zotero_add "${args[@]}"
}
