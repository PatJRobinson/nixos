# Interactive shells

Bash is the default login shell, configured at the NixOS level in
modules/users.nix. Apply both NixOS and Home Manager changes and start a fresh
login session to use it by default. Run `bash` to use it in an existing terminal.

Run `zsh` for the original Powerlevel10k setup, including its existing history
and fzf history search. Use `exit` to return to Bash.

Starship recreates the transparent Powerlevel10k layout, Nerd Font icons,
green/red prompt character, Git indicators, right-side context and clock.
Directory shortening and Git formatting approximate Powerlevel10k.
ble.sh supplies highlighting, history suggestions and completion menus.
Use Right at the end of the line to accept a suggestion, Tab for completion,
and Ctrl-R for fzf history search.

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
