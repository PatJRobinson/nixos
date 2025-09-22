# taken from dotfiles at https://github.com/patjrobinson/waybartheme.git
{ waybarParams, ... }:
let
  params = waybarParams;
in {
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        "layer" = "top";
        "position" = "top";
        "autohide" = true;
        "autohide-blocked" = false;
        "exclusive" = true;
        "passthrough" = false;
        "gtk-layer-shell" = true;

        "modules-left" = [
          "custom/archicon"
          "clock"
          "cpu"
          "memory"
          "disk"
          "temperature"
        ];

        "modules-center" = [
          "hyprland/workspaces"
        ];

        "modules-right" = [
          "wlr/taskbar"
          "idle_inhibitor"
          "pulseaudio"
          "network"
          "battery"
          "hyprland/language"
        ];

        # module configs
        "custom/archicon" = {
          format = "❄️";
          "on-click" = "rofi -show drun";
          tooltip = false;
        };

        clock = {
          timezone = "Europe/London";
          format = "{:%I:%M  %d, %m}";
          "tooltip-format" = "{calendar}";
          calendar = { mode = "month"; };
        };

        cpu = {
          format = "{usage}% ";
          tooltip = true;
          "tooltip-format" = "CPU usage: {usage}%\nNúcleos: {cores}";
        };

        memory = {
          format = "{}% 󰍛";
          tooltip = true;
          "tooltip-format" = "RAM usage: {used} / {total} ({percentage}%)";
        };

        disk = {
          format = "{percentage_used}% ";
          tooltip = true;
          "tooltip-format" = "Used on {path}: {used} / {total} ({percentage_used}%)";
        };

        temperature = {
          "hwmon-path" = params.hwmonPath;
          format = "CPU {temperatureC}°C {icon}";
          tooltip = true;
          "tooltip-format" = "Temperature: {temperatureC}°C\nCritical at > 80°C";
          "format-icons" = [ "" ];
        };

        "hyprland/workspaces" = {
          format = "{icon}";
          "format-icons" = { default = ""; active = ""; };
          "persistent-workspaces" = { "*" = 2; };
          "disable-scroll" = true;
          "all-outputs" = true;
          "show-special" = true;
        };

        "wlr/taskbar" = {
          format = "{icon}";
          "all-outputs" = true;
          "active-first" = true;
          "tooltip-format" = "{name}";
          "on-click" = "activate";
          "on-click-middle" = "close";
          "ignore-list" = [ "rofi" ];
        };

        idle_inhibitor = {
          format = "{icon}";
          "format-icons" = { activated = ""; deactivated = ""; };
        };

        pulseaudio = {
          format = "{volume}% {icon}";
          "format-muted" = " {format_source}";
          "format-icons" = { default = [ "" "" ]; };
        };

        battery = if params ? battery then 
          {
            interval = 60;
            states = { warning = 30; critical = 15; };
            format = "{capacity}% {icon}";
            "format-icons" = [ "" "" "" "" "" ];
          }
        else {};

        network = {
          format = "{ifname}";
          "format-ethernet" = "{ifname} 󰈀";
          "format-disconnected" = " ";
          "tooltip-format" = " {ifname} via {gwaddr}";
          "tooltip-format-ethernet" = " {ifname} {ipaddr}/{cidr}";
          "tooltip-format-disconnected" = "Disconnected";
          "max-length" = 50;
        };

        "hyprland/language" = {
          format = "{} ";
          "on-click" = "hyprctl switchxkblayout at-translated-set-2-keyboard next";
          "format-es" = "ESP";
          "format-en" = "ENG";
        };
      };
    };

    # your CSS as uploaded (keeps your exact styling). See file upload. :contentReference[oaicite:1]{index=1}
    style = ''
/* -- Global rules -- */
* {
  border: none;
  font-family: "JetbrainsMono Nerd Font";
  font-size: 15px;
  min-height: 10px;
}

window#waybar {
  background: rgba(34, 36, 54, 0.6);
}

window#waybar.hidden {
  opacity: 0.2;
}

/* - Genera rules for visible modules -- */
#custom-archicon,
#clock,
#cpu,
#memory,
#disk,
#temperature,
#idle_inhibitor,
#pulseaudio,
#battery,
#network,
#language {
  color: #161320;
  margin-top: 6px;
  margin-bottom: 6px;
  padding-left: 10px;
  padding-right: 10px;
  transition: none;
}

/* Separation to the left */
#custom-archicon,
#cpu,
#idle_inhibitor {
  margin-left: 5px;
  border-top-left-radius: 10px;
  border-bottom-left-radius: 10px;
}

/* Separation to the rigth */
#clock,
#temperature,
#language {
  margin-right: 5px;
  border-top-right-radius: 10px;
  border-bottom-right-radius: 10px;
}

/* -- Specific styles -- */

/* Modules left */
#custom-archicon {
  font-size: 20px;
  color: #89B4FA;
  background: #161320;
  padding-right: 17px;
}

#clock {
  background: #ABE9B3;
}

#cpu {
  background: #96CDFB;
}

#memory {
  background: #DDB6F2;
}

#disk {
  background: #F5C2E7;
}

#temperature {
  background: #F8BD96;
}

/* Modules center */
#workspaces {
  background: rgba(0, 0, 0, 0.5);
  border-radius: 10px;
  margin: 6px 5px;
  padding: 0px 6px;
}

#workspaces button {
  color: #B5E8E0;
  background: transparent;
  padding: 4px 4px;
  transition: color 0.3s ease, text-shadow 0.3s ease, transform 0.3s ease;
}

#workspaces button.occupied {
  color: #A6E3A1;
}

#workspaces button.active {
  color: #89B4FA;
  text-shadow: 0 0 4px #ABE9B3;
}

#workspaces button:hover {
  color: #89B4FA;
}

#workspaces button.active:hover {}

/* Modules right */
#taskbar {
  background: transparent;
  border-radius: 10px;
  padding: 0px 5px;
  margin: 6px 5px;
}

#taskbar button {
  padding: 0px 5px;
  margin: 0px 3px;
  border-radius: 6px;
  transition: background 0.3s ease;
}

#taskbar button.active {
  background: rgba(34, 36, 54, 0.5);
}

#taskbar button:hover {
  background: rgba(34, 36, 54, 0.5);
}

#idle_inhibitor {
  background: #B5E8E0;
  padding-right: 15px;
}

#battery {
  background: #96CDFB;
  padding: 0 10px;
  font-size: 15px; /* match other modules */
}

#battery .icon {
  font-size: 0.85em; /* shrink icon to match text */
}

#pulseaudio {
  color: #1A1826;
  background: #F5E0DC;
}

#pulseaudio_slider {
  color: #1A1826;
  background: #E8A2AF;
}

#network {
  background: #CBA6F7;
  padding-right: 13px;
}

#language {
  background: #A6E3A1;
  padding-right: 15px;
}

/* === Optional animation === */
@keyframes blink {
  to {
    background-color: #BF616A;
    color: #B5E8E0;
  }
}
    '';
  };
}
