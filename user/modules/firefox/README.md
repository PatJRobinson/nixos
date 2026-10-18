# Firefox with a qute-style Dayfox interface

`../firefox.nix` is imported by `user/home.nix`. All profiles have a slim top
tab strip, a bottom URL bar, Tridactyl and the colours from the existing
`dayfox.json`. Normal pages keep their own colours.

The tab strip and bottom URL bar are both 18px tall, with 12px text. The bottom
row uses plain text on the background with Firefox's security indicators,
without a rounded address-field background. Hint mode shows labels without
recolouring or outlining page elements.

New tabs open a minimal Dayfox page with DuckDuckGo search, YouTube
subscriptions, GitHub, Nix Packages and NixOS Wiki. Tridactyl's `f`, `o`, `O`,
`J` and `K` work on it. Edit `startPageShortcuts` in `firefox.nix` to change
the links, and `startpage.html` to change its layout. There are no external
scripts, fonts or requests until you search or follow a link.

The `firefox-startpage` user service serves only the generated static page at
`http://127.0.0.1:8766/`. Home Manager starts it during activation and the user
session starts it on login. It listens on loopback, not the network. The port
and URL are configured together in `firefox.nix`. After rebuilding, run
`:source` or restart Firefox for Tridactyl to pick up the new-tab URL.
If the page is unavailable, check `systemctl --user status firefox-startpage`.

The full bottom toolbar appears on hover or Ctrl+L, including the application
menu, extensions and permission controls. The site identity/security indicator
remains visible. F11 and video fullscreen hide the bottom row.

## Rebuild and first launch

The local flake pins a snapshot of the generator, so refresh that input first:

```sh
cd ~/nixos/config
nix flake update config-builder
home-manager switch --flake .#paddy@pj-laptop
firefox -P personal
```

The browser configuration lives in Home Manager. Also rebuild NixOS once with
`sudo nixos-rebuild switch --flake .#pj-laptop` to remove the old system browser
package and wrapper. Fully quit Firefox before switching generations so it reads the new CSS and
preferences at startup. Hyprland Super+Shift+B launches the personal Firefox
profile; Super+Shift+F also launches Firefox. HTTP/HTTPS links use it by default.
A fresh desktop session picks up the BROWSER and Wayland environment variables.

Profiles are named `personal` (default, `~/.mozilla/firefox/nix-personal`),
`work` (`~/.mozilla/firefox/nix-work`) and `google`
(`~/.mozilla/firefox/nix-google`). Launch the latter profiles with
`firefox -P work` / `firefox -P google`, or the **Firefox (Work)** /
**Firefox (Google)** application entries in rofi. The Google launcher uses the
Google G icon, tinted to the desktop palette for Softlight. It runs Firefox
directly without Firejail and opens YouTube on startup. Cookies, tabs, history
and logins are separate.
Existing profile directories are not overwritten; Home Manager
owns the profile registry, so add any existing profile you want to retain to
`programs.firefox.profiles` before activation if it reports a file conflict.

Firefox downloads the signed Tridactyl, uBlock Origin and Unhook extensions
from Mozilla on first launch, so that step requires internet access. They are
installed by policy and update through Firefox independently of Nix rebuilds.
The native Tridactyl connector is installed by Nix; do not run `:nativeinstall`.

After the extensions finish installing:

1. Open a normal website and run `:native` to check the connector, then `:source`
   to load bindings immediately if this is the first installation.
   `O` should show a blank `tabopen` prompt. If it instead pre-fills the current
   URL, Tridactyl is still using its defaults: run `:source`. If that fails,
   `:native` checks the connector and `:findrc` shows the configuration path.
2. Press `o` and `O` to check current-tab and new-tab completion, and `f` to
   check link hints. The command line and hints should use Dayfox colours.
3. Press Ctrl+L and check the bottom URL bar's upward autocomplete, application
   menu and extensions menu. Open Unhook from the extensions menu and choose
   which YouTube elements to hide. Its popup choices remain mutable per
   profile; they are not reset on rebuild.
4. Visit `about:policies` and confirm there are no errors. uBlock Origin's
   dashboard should show its standard lists and Quick fixes enabled. Check a
   YouTube video while logged into your normal account.
5. Open Firefox Sync using `,s` or the application menu and sign into a Mozilla
   account. Enable Sync and confirm **Bookmarks** and **Open tabs** are selected.
   Repeat in the matching profile on each other machine using the same account.
   Run `:source` after rebuilding to load the new `,T` shortcut for remote tabs.

## Tab and bookmark sync

The declarative profile settings enable bookmarks and open tabs, and disable
history, passwords, addresses, payment cards, extensions and preference sync.
Nix supplies the extensions, appearance and bindings independently on each
machine. Firefox reads these defaults on startup; after signing in for the
first time, restart Firefox and check the selections in `,s` again.

Device names come from `hostParams.name` plus the profile name, for example
`pj-laptop / personal` and `pj-laptop / work`. Give each machine a distinct
`hostParams.name` in its local flake. Device IDs, encryption keys and login
tokens stay mutable in Firefox's own profile; do not copy a signed-in profile
directory to another machine. Account sign-in is the one-time manual step.

Use `,T` to open Firefox View's **Tabs from other devices** page, then choose a
device and open its tabs. Bookmarks merge across the account. Open-tab sync
publishes each device's tab list; it does not continuously mirror every
open/close action into every window. Use **Sync now** in the account menu on
both devices when checking a freshly added bookmark or tab.

Firefox Sync is account-wide, not partitioned by the local profile name.
Signing multiple profiles into the same Mozilla account merges their
synced bookmarks and lists them as separate devices. Use separate Mozilla
accounts if those profiles should retain separate bookmark collections.

Troubleshooting: `,s` shows login status and sync selections, and
`about:sync-log` contains Sync's diagnostic logs. Firefox View and Sync settings
are internal pages, so use Firefox's controls there and Ctrl+, to return to
Tridactyl. The setup needs no additional server or background sync daemon.

## Keyboard reference

These bindings apply on pages where Firefox permits Tridactyl to run.

| Keys | Action |
| --- | --- |
| `o` / `O` | Open/search in current/new tab, with history and bookmark completion |
| `go` / `gO` | Edit current URL for current/new tab |
| `f` / `F` | Follow a link in current/background tab |
| `J` / `K` | Next/previous tab |
| `d` / `D` or `u` | Close / reopen a closed tab |
| `m` | Toggle bookmark for current page |
| `b` / `B` | Search bookmarks for current/new tab |
| `,t` | Search open tabs |
| `,T` | Open tabs from other synced devices |
| `,h` | Search history/bookmarks |
| `H` / `L` | Back/forward |
| `j`, `k`, `gg`, `G`, `/`, `n`, `N` | Scroll and search |
| `yy` | Copy current URL |
| `,s` / `,a` / `,p` | Sync settings / extensions / profiles |
| `,r` | Reload the declarative Tridactyl configuration |
| `,?` | Tridactyl help |
| Shift+Escape | Pass site keybindings through; repeat to return |
| Ctrl+, | Global escape hatch from restricted/internal pages |
| Ctrl+L | Focus URL bar and reveal full toolbar |
| F11 | Browser fullscreen toggle |

## Editing and recovery

- `userChrome.css`: browser layout. CSS uses Firefox's internal selectors and
  may need adapting after Firefox updates; it still needs visual verification
  on your machine.
- `userContent.css`: colours for built-in blank/home pages.
- `tridactylrc` and `tridactyl-dayfox.css`: commands, bindings and theme. Rebuild,
  then restart Firefox or run `:source` (`,r`). Native self-updates are disabled
  with `nativeinstallcmd`; Nix owns the connector.
- `startpage.html` and `startPageShortcuts` in `firefox.nix`: new-tab layout and
  links. The new-tab URL is substituted into `tridactylrc` by Nix.
- `ublock-filters.txt`: custom uBlock rules, one per line. This file replaces
  **My filters** at Firefox startup, so put persistent changes here. Filter-list
  selection lives in `firefox.nix`; list contents continue updating normally.
- Extension installation policies apply to every profile opened with this
  wrapped Firefox, including existing profiles. Unhook's toggles stay editable.

For a temporary return to stock Firefox, open `about:config` using Ctrl+L,
set `toolkit.legacyUserProfileCustomizations.stylesheets` to false and restart.
The next Home Manager activation restores its declarative value. For a lasting
rollback, remove the Firefox module import or change that setting in Nix.

Tridactyl cannot control all Firefox internal pages, dialogs, the PDF viewer
or pages before they load. Ctrl+L, Ctrl+Tab and Ctrl+, remain available as
fallbacks. Normal Firefox menus are accessible using Alt or the revealed
application-menu button.
