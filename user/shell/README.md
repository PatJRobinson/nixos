# Interactive shells

Bash is the default login shell, configured at the NixOS level in
modules/users.nix. Apply both NixOS and Home Manager changes and start a fresh
login session to use it by default. Run `bash` to use it in an existing terminal.

Run `zsh` for the original Powerlevel10k setup, including its existing history
and fzf history search. Use `exit` to return to Bash.

Starship recreates the transparent Powerlevel10k layout, Nerd Font icons,
green/red prompt character and Git indicators.
Directory shortening and Git formatting approximate Powerlevel10k.
Flyline supplies highlighting, inline history suggestions and native fuzzy Tab
completion. Mouse capture is disabled, and the cursor uses the terminal's normal
rendering instead of Flyline's fading animation.
Use Right at the end of the line to accept a suggestion, Tab for completion,
Ctrl-R for fzf history search, and Up/Down to search history by prefix.
For example, `cd gen` followed by Tab searches for matching directories such
as `config-generator`. Ctrl-R, Ctrl-T and Alt-C retain their fzf actions.
In Flyline, `**` explicitly requests fzf completion instead of the native menu.

The generator's `mkHome` accepts `enableFlyline`, defaulting to `true`. Set
`enableFlyline = false;` in a host's `mkHome` call to omit Flyline there and
advertise a disabled preference to subsequent SSH connections.

Local Bash sessions default to `FLYLINE_ENABLE=1` when enabled in the generator
(`0` when disabled). The shared SSH client sends
this preference and the shared SSH server accepts it, so SSH from your configured
laptop or desktop keeps Flyline. SSH from other clients falls back to Bash's
normal Readline editor. A remote shell never enables the flag on its own, so
logging in through another configured machine does not change that fallback.
Apply Home Manager on both machines and the NixOS OpenSSH change on the server
before reconnecting; the preference can only cross intermediate SSH hops whose
clients and servers also forward/accept it. `ssh -J` preserves the direct
client-to-destination SSH connection and needs no preference handling on the jump
host.

Neovim's embedded terminals use Readline. For a temporary opt-out, run
`FLYLINE_DISABLE=1 bash` or `FLYLINE_DISABLE=1 ssh HOST`; the flag is inherited by
child shells and forwarded by SSH. Run `enable -d flyline` to disable Flyline in
an already-running shell. After applying this configuration, run `exec bash`
in an existing SSH session and reopen any existing Neovim terminal buffers.

The existing fzf, direnv, lsd and Yazi Home Manager modules also integrate with
Bash. Custom functions live in functions.sh and are shared with Zsh.

Bash keeps its own ~/.bash_history. To seed it from Zsh, close other Bash
sessions and run `import-zsh-history` inside Bash after applying Home Manager.
You can supply an alternative Zsh history path as its first argument.

The importer retains existing Bash entries, backs up the Bash history file to
`~/.bash_history.before-zsh-import`, and reloads the merged history into the
current shell for Ctrl-R and suggestions. It leaves Zsh history unchanged and
refuses a repeated import. Multiline commands are preserved; original command
timestamps are not. Commands retain their original syntax, including Zsh syntax.
