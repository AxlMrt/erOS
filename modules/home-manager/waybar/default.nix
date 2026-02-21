{
  pkgs,
  config,
  ...
}: let
  c = config.eros.theme.active.palette;
  scriptsDir = ./scripts;
  scripts = builtins.attrNames (builtins.readDir scriptsDir);
in {
  home.packages = with pkgs; [
    brightnessctl
    lm_sensors
    libnotify
    networkmanager
    playerctl
    pulseaudio
    upower
    (python3.withPackages (ps: [ps.requests]))
  ];

  home.file = builtins.listToAttrs (
    map (name: {
      name = ".config/waybar/scripts/" + name;
      value = {
        source = "${scriptsDir}/${name}";
        executable = true;
      };
    })
    scripts
  );

  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    settings = [
      {
        layer = "top";
        exclusive = true;
        passthrough = false;
        position = "top";
        spacing = 3;
        "fixed-center" = true;
        ipc = true;
        "margin-top" = 4;
        "margin-left" = 8;
        "margin-right" = 8;

        modules-left = [
          "custom/menu"
          "custom/separator#blank"
          "custom/playerctl"
          "custom/separator#blank"
          "hyprland/window"
        ];

        modules-center = [
          "hyprland/workspaces#rw"
          "clock"
          "custom/separator#blank"
          "idle_inhibitor"
        ];

        modules-right = [
          "group/app_drawer"
          "custom/separator#blank"
          "group/notify"
          "custom/separator#blank"
          "tray"
          "custom/separator#blank"
          "group/laptop"
          "custom/separator#blank"
          "group/mobo_drawer"
          "custom/separator#blank"
          "group/audio"
          "custom/separator#blank"
          "group/status"
        ];

        "hyprland/workspaces#rw" = {
          "disable-scroll" = true;
          "all-outputs" = true;
          "warp-on-scroll" = false;
          "sort-by-number" = true;
          "show-special" = false;
          "on-click" = "activate";
          "persistent-workspaces" = {"*" = 5;};
          format = "{icon} {windows}";
          "format-window-separator" = " ";
          "window-rewrite-default" = " ";
          "window-rewrite" = {
            "class<firefox|org.mozilla.firefox|librewolf|floorp|mercury-browser|[Cc]hachy-browser>" = " ";
            "class<Chromium|Thorium|[Cc]hrome|brave-browser>" = " ";
            "class<kitty|konsole|com.mitchellh.ghostty|org.wezfurlong.wezterm>" = " ";
            "class<VSCode|code-url-handler|code-oss|codium|codium-url-handler|VSCodium>" = "󰨞 ";
            "class<[Tt]elegram-desktop|org.telegram.desktop|io.github.tdesktop_x64.TDesktop>" = " ";
            "class<discord|[Ww]ebcord|Vesktop>" = " ";
            "class<[Ss]potify>" = " ";
          };
        };

        "hyprland/window" = {
          format = "{}";
          "max-length" = 28;
          "separate-outputs" = true;
          rewrite = {
            "(.*) — Mozilla Firefox" = "  $1";
            "(.*) - zsh" = "> [$1]";
            "(.*) - fish" = "> [$1]";
          };
        };

        "group/app_drawer" = {
          orientation = "inherit";
          drawer = {
            "transition-duration" = 400;
            "children-class" = "custom-menu";
            "transition-left-to-right" = true;
          };
          modules = [
            "custom/menu"
            "custom/tty"
          ];
        };

        "group/mobo_drawer" = {
          orientation = "inherit";
          drawer = {
            "transition-duration" = 400;
            "children-class" = "cpu";
            "transition-left-to-right" = true;
          };
          modules = [
            "custom/cpu_temp"
            "cpu"
            "memory"
          ];
        };

        "group/laptop" = {
          orientation = "inherit";
          modules = [
            "backlight"
            "battery"
          ];
        };

        "group/audio" = {
          orientation = "inherit";
          drawer = {
            "transition-duration" = 400;
            "children-class" = "pulseaudio";
            "transition-left-to-right" = true;
          };
          modules = [
            "pulseaudio"
            "custom/wifi_status"
          ];
        };

        "group/notify" = {
          orientation = "inherit";
          drawer = {
            "transition-duration" = 400;
            "children-class" = "custom-swaync";
            "transition-left-to-right" = false;
          };
          modules = [
            "custom/swaync"
          ];
        };

        "group/status" = {
          orientation = "inherit";
          drawer = {
            "transition-duration" = 400;
            "children-class" = "custom-power";
            "transition-left-to-right" = false;
          };
          modules = [
            "network"
            "custom/power"
          ];
        };

        "custom/menu" = {
          format = "";
          "on-click" = "pkill rofi || rofi -show drun -modi run,drun,window";
          "tooltip-format" = "Rofi Menu";
          tooltip = true;
        };

        "custom/tty" = {
          format = "";
          "on-click" = "kitty";
          "tooltip-format" = "Launch terminal";
          tooltip = true;
        };

        "custom/playerctl" = {
          format = "<span>{}</span>";
          "return-type" = "json";
          "max-length" = 32;
          "exec-if" = "command -v playerctl >/dev/null 2>&1";
          exec = "playerctl -a metadata --format '{\"text\": \"{{artist}} {{markup_escape(title)}}\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F";
          "on-click-middle" = "playerctl play-pause";
          "on-click" = "playerctl previous";
          "on-click-right" = "playerctl next";
          "scroll-step" = 5.0;
        };

        "custom/cpu_temp" = {
          "return-type" = "json";
          exec = "$HOME/.config/waybar/scripts/cpu-temp.sh";
          interval = 4;
          tooltip = true;
        };

        "custom/wifi_status" = {
          "return-type" = "json";
          exec = "$HOME/.config/waybar/scripts/wifi-status.sh";
          interval = 3;
          tooltip = true;
        };

        "custom/swaync" = {
          tooltip = true;
          "tooltip-format" = "Left Click: notifications\nRight Click: Do Not Disturb";
          format = "{} {icon}";
          "format-icons" = {
            notification = "<span foreground='${c.error}'><sup></sup></span>";
            none = "";
            "dnd-notification" = "<span foreground='${c.error}'><sup></sup></span>";
            "dnd-none" = "";
            "inhibited-notification" = "<span foreground='${c.error}'><sup></sup></span>";
            "inhibited-none" = "";
            "dnd-inhibited-notification" = "<span foreground='${c.error}'><sup></sup></span>";
            "dnd-inhibited-none" = "";
          };
          "return-type" = "json";
          "exec-if" = "which swaync-client";
          exec = "swaync-client -swb";
          "on-click" = "sleep 0.1 && swaync-client -t -sw";
          "on-click-right" = "swaync-client -d -sw";
          escape = true;
        };

        "custom/power" = {
          format = "⏻";
          "on-click" = "$HOME/.config/waybar/scripts/power-menu.sh";
          "tooltip-format" = "Power menu";
          tooltip = true;
        };

        "custom/separator#blank" = {
          format = " ";
          interval = "once";
          tooltip = false;
        };

        clock = {
          interval = 1;
          format = " {:%H:%M}";
          "format-alt" = " {:%H:%M   %Y-%m-%d}";
          "tooltip-format" = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            "mode-mon-col" = 3;
            "weeks-pos" = "right";
            "on-scroll" = 1;
            format = {
              months = "<span color='${c.warn}'><b>{}</b></span>";
              days = "<span color='${c.fgMuted}'><b>{}</b></span>";
              weeks = "<span color='${c.accent}'><b>W{:%V}</b></span>";
              weekdays = "<span color='${c.fg}'><b>{}</b></span>";
              today = "<span color='${c.error}'><b><u>{}</u></b></span>";
            };
          };
        };

        "idle_inhibitor" = {
          tooltip = true;
          "tooltip-format-activated" = "Idle inhibitor active";
          "tooltip-format-deactivated" = "Idle inhibitor inactive";
          format = "{icon}";
          "format-icons" = {
            activated = "";
            deactivated = "";
          };
        };

        cpu = {
          format = "{usage}% 󰍛";
          interval = 2;
          "format-alt" = "{icon0}{icon1}{icon2}{icon3} {usage:>2}% 󰍛";
          "format-icons" = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
        };

        memory = {
          interval = 4;
          format = "{used:0.1f}G 󰾆";
          "format-alt" = "{percentage}% 󰾆";
          tooltip = true;
          "tooltip-format" = "{used:0.1f}GB/{total:0.1f}GB";
        };

        backlight = {
          interval = 2;
          format = "{icon} {percent}%";
          "format-icons" = ["" "" "" "󰃝" "󰃞" "󰃟" "󰃠"];
          "on-scroll-up" = "$HOME/.config/waybar/scripts/brightness-control.sh -o i";
          "on-scroll-down" = "$HOME/.config/waybar/scripts/brightness-control.sh -o d";
          "tooltip-format" = "backlight {percent}%";
        };

        battery = {
          align = 0;
          rotate = 0;
          "full-at" = 100;
          "design-capacity" = false;
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          "format-charging" = " {capacity}%";
          "format-plugged" = "󱘖 {capacity}%";
          "format-alt" = "{icon} {time}";
          "format-icons" = [
            "󰂎"
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          tooltip = true;
          "tooltip-format" = "{timeTo} {power}w";
        };

        network = {
          format = "{ifname}";
          "format-wifi" = "{icon}";
          "format-ethernet" = "󰌘";
          "format-disconnected" = "󰌙";
          "tooltip-format" = "{ipaddr}  {bandwidthUpBits}  {bandwidthDownBits}";
          "tooltip-format-wifi" = "{essid} {icon} {signalStrength}%";
          "tooltip-format-ethernet" = "{ifname} 󰌘";
          "tooltip-format-disconnected" = "󰌙 Disconnected";
          "format-icons" = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          "format-bluetooth" = "{icon} 󰂰 {volume}%";
          "format-muted" = "󰖁";
          "format-icons" = {
            headphone = "";
            "hands-free" = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" "󰕾" ""];
          };
          "scroll-step" = 5.0;
          "on-click" = "$HOME/.config/waybar/scripts/volume-control.sh -o o m";
          "on-scroll-up" = "$HOME/.config/waybar/scripts/volume-control.sh -o o i";
          "on-scroll-down" = "$HOME/.config/waybar/scripts/volume-control.sh -o o d";
          "tooltip-format" = "{icon} {desc} | {volume}%";
          "smooth-scrolling-threshold" = 1;
        };

        tray = {
          "icon-size" = 18;
          spacing = 4;
        };
      }
    ];

    style = ''
      * {
        font-family: "${config.eros.ui.fonts.mono}";
        font-weight: bold;
        min-height: 0;
        font-size: 97%;
      }

      window#waybar {
        transition-property: background-color;
        transition-duration: 0.5s;
        background: transparent;
        border-radius: 10px;
      }

      window#waybar.hidden {
        opacity: 0.2;
      }

      .modules-left,
      .modules-center,
      .modules-right {
        font-weight: bold;
        margin: 0 10px;
        margin-top: 4px;
        background: alpha(${c.bg}, 0.78);
        border: 1px solid alpha(${c.border}, 0.7);
        padding: 0 4px;
        border-radius: 20px;
      }

      #backlight,
      #battery,
      #clock,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #tray,
      #window,
      #workspaces,
      #idle_inhibitor,
      #custom-menu,
      #custom-power,
      #custom-swaync,
      #custom-playerctl,
      #custom-tty,
      #custom-cpu_temp,
      #custom-wifi_status {
        padding: 3px 6px;
      }

      #custom-menu { color: ${c.accent}; }
      #custom-power { color: ${c.error}; }
      #custom-swaync { color: ${c.accent}; }
      #custom-playerctl { color: ${c.fgMuted}; }
      #custom-wifi_status,
      #network { color: ${c.accent}; }
      #cpu,
      #pulseaudio { color: ${c.ok}; }
      #memory,
      #backlight,
      #idle_inhibitor { color: ${c.fgMuted}; }
      #window { color: ${c.fg}; }

      #battery {
        color: ${c.ok};
      }

      #battery.critical:not(.charging) {
        background-color: ${c.error};
        color: ${c.bg};
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      @keyframes blink {
        to { opacity: 0.45; }
      }

      #workspaces button {
        box-shadow: none;
        text-shadow: none;
        padding: 0 4px;
        border-radius: 9px;
        color: ${c.fgMuted};
        transition: all 0.2s ease-in-out;
      }

      #workspaces button:hover {
        border-radius: 10px;
        color: ${c.bg};
        background-color: ${c.surface};
        padding-left: 2px;
        padding-right: 2px;
      }

      #workspaces button.active {
        color: ${c.accent};
        border-radius: 10px;
        padding-left: 8px;
        padding-right: 8px;
      }

      #workspaces button.urgent {
        color: ${c.error};
      }

      #network.disconnected,
      #network.disabled,
      #custom-wifi_status.disconnected {
        background-color: alpha(${c.surface}, 0.9);
        color: ${c.fg};
      }

      tooltip {
        border-radius: ${toString config.eros.ui.radius}px;
        border: 1px solid alpha(${c.border}, 0.8);
        background: alpha(${c.bg}, 0.92);
        color: ${c.fg};
      }
    '';
  };
}
