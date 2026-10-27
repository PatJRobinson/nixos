# Brave for LinkedIn

Home Manager installs Brave alongside Firefox. Launch **Brave (LinkedIn)**
from Rofi, or run `brave-linkedin`. With no arguments it opens
`https://www.linkedin.com/`; supplied URLs open in the same profile.

The profile is named `linkedin` and lives under
`~/.config/BraveSoftware/Brave-LinkedIn/linkedin`. Its separate user-data
directory gives it a consistent `brave-linkedin` Wayland app ID even while
other Brave profiles are running. Rofi and Waybar use the LinkedIn logo in
the desktop's Dayfox foreground colour.

The original Brave Dayfox theme was removed in commit `11ae57a` when Firefox
replaced Brave. `../brave.nix` restores those colours using Firefox's shared
`dayfox.json` palette and loads the theme from the stable path
`~/.config/brave-dayfox`. Profile preferences are seeded only on first launch;
Brave manages subsequent changes and sign-ins.

From the local `config` directory, build and activate with:

```sh
home-manager switch \
  --flake 'path:.#paddy@pj-laptop' \
  --override-input config-builder 'path:../config-generator'
```

Restart Waybar after activation so it reloads the app mapping and icon theme.
