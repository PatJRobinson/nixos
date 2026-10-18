# Softlight

Visual adaptation of [mohsilas/softlight_rice](https://github.com/mohsilas/softlight_rice)
for this configuration's existing applications. The author's README specifies
Dayfox, a bright desktop with a shadow background, and a light launcher.
The individual upstream configuration files were unavailable during adaptation;
spacing, rounding and the original SVG wallpaper are approximations.

Select the theme in the local flake's `mkHostCfg` call. It defaults to
`softlight`:

```nix
theme = "gruvbox"; # optional override; defaults to "softlight"
```

From the local `config` directory, activate with:

```sh
home-manager switch \
  --flake 'path:.#paddy@pj-laptop' \
  --override-input config-builder 'path:../config-generator'
```

Log out of Hyprland and back in to refresh session environment variables,
Waybar and the wallpaper. No NixOS rebuild is needed. Neovim uses the existing
`NVIM_COLOURSCHEME=dayfox` and `NVIM_DARK_MODE=0` hooks; Nightfox is supplied
in Neovim's `site` directory so it survives Lazy's runtime-path reset and
appears in Telescope. The Neovim source is pinned to the user's revision
that already implements `NVIM_COLOURSCHEME`.

The existing display layout, bindings, window rules, startup commands,
Waybar modules and actions, shell functions, application choices and services
are retained. The wallpaper still uses the existing random-wallpaper script.

To restore the previous appearance, set `theme = "gruvbox";` in the local
flake's `mkHostCfg` call, rerun the activation command and log out and back in. The existing `darkMode`
toggle controls Gruvbox's light/dark variant; Softlight always uses light mode.
