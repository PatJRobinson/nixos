{ hyprParams, ... }:

let
  params = hyprParams;
  layout = if hyprParams.displayType == "ultrawide" then "master" else "dwindle";
  monitors = 
    if hyprParams.displayType == "ultrawide" then ''
      monitor=,preferred, auto, 1
    '' else
    if hyprParams.displayType == "dual" then ''
      monitor=eDP-1,preferred, auto, 1.566667
      monitor=DP-2,preferred, auto, 1
    '' else
    if hyprParams.displayType == "laptop" then ''
      monitor=eDP-1,preferred, auto, 1.566667
    '' else "";

in {
  home.file.".config/hypr/scripts".source = ../hyprland-scripts;
  home.file.".config/hypr/hyprland.conf".text = ''
################
### MONITORS ###
################

# See https://wiki.hyprland.org/Configuring/Monitors/
${monitors}

###################
### MY PROGRAMS ###
###################

# See https://wiki.hyprland.org/Configuring/Keywords/

# Set programs that you use
$terminal = ghostty
$fileManager = nautilus
$menu = wofi --show drun

#################
### AUTOSTART ###
#################

# Autostart necessary processes (like notifications daemons, status bars, etc.)
# Or execute your favorite apps at launch like this:

# exec-once = $terminal
# exec-once = nm-applet &
# exec-once = waybar & hyprpaper & firefox

exec-once = systemctl --user restart hyprpaper
exec-once = waybar & hyprpaper
exec-once = sleep 2; exec ~/.config/hypr/scripts/set-random-wallpaper.sh

#############################
### ENVIRONMENT VARIABLES ###
#############################

# See https://wiki.hyprland.org/Configuring/Environment-variables/

env = XCURSOR_SIZE,24
env = HYPRCURSOR_SIZE,24


###################
### PERMISSIONS ###
###################

# See https://wiki.hyprland.org/Configuring/Permissions/
# Please note permission changes here require a Hyprland restart and are not applied on-the-fly
# for security reasons

# ecosystem {
#no_update_news=true
#   enforce_permissions = 1
# }

# permission = /usr/(bin|local/bin)/grim, screencopy, allow
# permission = /usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland, screencopy, allow
# permission = /usr/(bin|local/bin)/hyprpm, plugin, allow


#####################
### LOOK AND FEEL ###
#####################

# Refer to https://wiki.hyprland.org/Configuring/Variables/

# https://wiki.hyprland.org/Configuring/Variables/#general
general {

    gaps_in = 5
    gaps_out = 20

    border_size = 2

    # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
    col.active_border = rgb(a89984)
    col.inactive_border = rgba(595959aa)

    # Set to true enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = false

    # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
    allow_tearing = false

    layout = ${layout}
}

# https://wiki.hyprland.org/Configuring/Variables/#decoration
decoration {
    rounding = 5
    rounding_power = 2

    # Change transparency of focused and unfocused windows
    active_opacity = 1.0
    inactive_opacity = 1.0

    shadow {
        enabled = true
        range = 4
        render_power = 3
        color = rgba(1a1a1aee)
    }

    # https://wiki.hyprland.org/Configuring/Variables/#blur
    blur {
        enabled = true
        size = 3
        passes = 1

        vibrancy = 0.1696
    }
}

# https://wiki.hyprland.org/Configuring/Variables/#animations
animations {
    enabled = yes, please :)

    # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

    bezier = easeOutQuint,0.23,1,0.32,1
    bezier = easeInOutCubic,0.65,0.05,0.36,1
    bezier = linear,0,0,1,1
    bezier = almostLinear,0.5,0.5,0.75,1.0
    bezier = quick,0.15,0,0.1,1

    animation = global, 1, 10, default
    animation = border, 1, 5.39, easeOutQuint
    animation = windows, 1, 4.79, easeOutQuint
    animation = windowsIn, 1, 4.1, easeOutQuint, popin 87%
    animation = windowsOut, 1, 1.49, linear, popin 87%
    animation = fadeIn, 1, 1.73, almostLinear
    animation = fadeOut, 1, 1.46, almostLinear
    animation = fade, 1, 3.03, quick
    animation = layers, 1, 3.81, easeOutQuint
    animation = layersIn, 1, 4, easeOutQuint, fade
    animation = layersOut, 1, 1.5, linear, fade
    animation = fadeLayersIn, 1, 1.79, almostLinear
    animation = fadeLayersOut, 1, 1.39, almostLinear
    animation = workspaces, 1, 1.94, almostLinear, fade
    animation = workspacesIn, 1, 1.21, almostLinear, fade
    animation = workspacesOut, 1, 1.94, almostLinear, fade
}

# Ref https://wiki.hyprland.org/Configuring/Workspace-Rules/
# "Smart gaps" / "No gaps when only"
# uncomment all if you wish to use that.
# workspace = w[tv1], gapsout:0, gapsin:0
# workspace = f[1], gapsout:0, gapsin:0
# windowrule = bordersize 0, floating:0, onworkspace:w[tv1]
# windowrule = rounding 0, floating:0, onworkspace:w[tv1]
# windowrule = bordersize 0, floating:0, onworkspace:f[1]
# windowrule = rounding 0, floating:0, onworkspace:f[1]

# See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
dwindle {
    pseudotile = true # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
    preserve_split = true # You probably want this
}

# See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
master {
    orientation = center                 # keep master in the middle
    mfact = 0.34                         # master width fraction (0.34 => ~1/3 of screen)
    slave_count_for_center_master = 0    # 0 => always keep master centered (even single window)
    new_status = slave                   # new windows become slaves (adjust to taste)
    new_on_active = after
    smart_resizing = true
}

# https://wiki.hyprland.org/Configuring/Variables/#misc
misc {
    force_default_wallpaper = 1 # Set to 0 or 1 to disable the anime mascot wallpapers
    disable_hyprland_logo = true # If true disables the random hyprland logo / anime girl background. :(
}


#############
### INPUT ###
#############

# https://wiki.hyprland.org/Configuring/Variables/#input
input {
    kb_layout = us
    kb_variant =
    kb_model =
    kb_options =
    kb_rules =

    kb_options = caps:escape

    follow_mouse = 1

    sensitivity = 0 # -1.0 - 1.0, 0 means no modification.

    touchpad {
        natural_scroll = false
    }
}


# Example per-device config
# See https://wiki.hyprland.or0/Configuring/Keywords/#per-device-input-configs for more
device {
    name = epic-mouse-v1
    sensitivity = -0.5
}


###################
### KEYBINDINGS ###
###################

# See https://wiki.hyprland.org/Configuring/Keywords/
$mainMod = SUPER # Sets "Windows" key as main modifier
$moonlightMod = CTRL

# Screen brightness
bind = , XF86MonBrightnessUp, exec, ~/.config/hypr/scripts/brightness_inc.sh 
bind = , XF86MonBrightnessDown, exec, ~/.config/hypr/scripts/brightness_dec.sh 

bind = SUPER, C, exec, ~/.config/hypr/scripts/fullscreen_toggle.sh 2>>~/.local/state/fullscreen_move.log
# Send focused window to workspace 1..9 with SUPER+ALT+[number]
bind = SUPER_ALT, 1, movetoworkspace, 1
bind = SUPER_ALT, 2, movetoworkspace, 2
bind = SUPER_ALT, 3, movetoworkspace, 3
bind = SUPER_ALT, 4, movetoworkspace, 4
bind = SUPER_ALT, 5, movetoworkspace, 5
bind = SUPER_ALT, 6, movetoworkspace, 6
bind = SUPER_ALT, 7, movetoworkspace, 7
bind = SUPER_ALT, 8, movetoworkspace, 8
bind = SUPER_ALT, 9, movetoworkspace, 9

# Move focused window to next workspace
bind = SUPER_ALT, RIGHT, movetoworkspace, r+1

# Move focused window to previous workspace
bind = SUPER_ALT, LEFT, movetoworkspace, r-1

# Swap focused window with master
bind = SUPER, Return, layoutmsg, swapwithmaster

# Swap next and prev
bind = SUPER, bracketleft, layoutmsg, swapprev
bind = SUPER, bracketright, layoutmsg, swapnext

# Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
bind = $mainMod, d, exec, rofi -show drun
bind = $mainMod, w, exec, rofi -show window
bind = $mainMod SHIFT, L, exec, hyprlock
bind = $mainMod, f, exec, $fileManager
bind = $mainMod SHIFT, t, exec, $terminal
bind = $moonlightMod SHIFT, t, exec, $terminal
bind = $mainMod SHIFT, f, exec, firefox
bind = $mainMod SHIFT, c, exec, ungoogled-chromium-wayland
#bind = $mainMod SHIFT, b, exec, brave-google
bind = $mainMod SHIFT, b, exec, qute-casual
bind = $mainMod SHIFT, o, exec, obsidian
bind = $mainMod SHIFT, s, exec, steam
bind = $moonlightMod SHIFT, s, exec, steam
bind = $mainMod SHIFT, m, exec, moonlight
bind = $mainMod, n, exec, \
  hyprctl dispatch togglefloating && \
  hyprctl dispatch togglefloating
bind = $mainMod, q, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, $menu
bind = $mainMod, P, pseudo, # dwindle
bind = $mainMod, o, togglesplit, # dwindle

# Move focus with mainMod + arrow keys
bind = $mainMod, h, movefocus, l
bind = $mainMod, l, movefocus, r
bind = $mainMod, k, movefocus, u
bind = $mainMod, j, movefocus, d

# Switch workspaces with mainMod + [0-9]
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move active window to a workspace with mainMod + SHIFT + [0-9]
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Example special workspace (scratchpad)
bind = $mainMod, S, togglespecialworkspace, magic
bind = $mainMod SHIFT, S, movetoworkspace, special:magic

# Scroll through existing workspaces with mainMod + scroll
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Laptop multimedia keys for volume and LCD brightness
bindel = ,XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
bindel = ,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bindel = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bindel = ,XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
bindel = ,XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+
bindel = ,XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-

# Requires playerctl
bindl = , XF86AudioNext, exec, playerctl next
bindl = , XF86AudioPause, exec, playerctl play-pause
bindl = , XF86AudioPlay, exec, playerctl play-pause
bindl = , XF86AudioPrev, exec, playerctl previous

##############################
### WINDOWS AND WORKSPACES ###
##############################

# See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
# See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

# Example windowrule
# windowrule = float,class:^(kitty)$,title:^(kitty)$

# Ignore maximize requests from apps. You'll probably like this.
windowrule = suppressevent maximize, class:.*

# Fix some dragging issues with XWayland
windowrule = nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0

  '';

  home.file.".config/hypr/hyprpaper.conf".text = ''
    # empty config so hyprpaper doesn’t crash
  '';
  home.file.".config/hypr/hyprlock.conf".source = ./hyprlock/hyprlock.conf;
}
