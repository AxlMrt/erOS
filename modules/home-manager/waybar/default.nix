{
  pkgs,
  config,
  ...
}: let
  scriptsDir = ./scripts;
  scripts = builtins.attrNames (builtins.readDir scriptsDir);
  themectl = "/etc/profiles/per-user/${config.home.username}/bin/eros-themectl";
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
    systemd.enable = true;
    package = pkgs.waybar;
    settings = [
      {
        layer = "top";
        exclusive = true;
        passthrough = false;
        position = "top";
        spacing = 0;
        "fixed-center" = true;
        ipc = true;
        reload_style_on_change = true;
        "on-sigusr2" = "reload";
        "margin-top" = 8;
        "margin-left" = 8;
        "margin-right" = 8;

        modules-left = [
          "custom/theme_switch"
          "custom/wallpaper_switch"
          "custom/menu"
          "custom/playerctl"
          "hyprland/window"
        ];

        modules-center = [
          "hyprland/workspaces#rw"
          "clock"
          "idle_inhibitor"
        ];

        modules-right = [
          "group/app_drawer"
          "group/notify"
          "tray"
          "group/laptop"
          "group/mobo_drawer"
          "group/audio"
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
          "on-click" = "pkill rofi || rofi -show drun -modi run,drun,window -theme $HOME/.config/eros/active/theme/rofi.rasi";
          "tooltip-format" = "Rofi Menu";
          tooltip = true;
        };

        "custom/theme_switch" = {
          "return-type" = "json";
          exec = "${themectl} status-theme";
          interval = 1;
          "on-click" = "sh -lc '${themectl} next >/dev/null 2>&1 &'";
          tooltip = true;
        };

        "custom/wallpaper_switch" = {
          "return-type" = "json";
          exec = "${themectl} status-wallpaper";
          interval = "once";
          "on-click" = "sh -lc '${themectl} wallpaper next >/dev/null 2>&1 &'";
          "on-click-right" = "sh -lc '${themectl} wallpaper default >/dev/null 2>&1 &'";
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
            notification = " ";
            none = "";
            "dnd-notification" = " ";
            "dnd-none" = "";
            "inhibited-notification" = " ";
            "inhibited-none" = "";
            "dnd-inhibited-notification" = " ";
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

        clock = {
          interval = 1;
          format = "  {:%H:%M}";
          "format-alt" = "  {:%H:%M  %Y-%m-%d}";
          "tooltip-format" = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            "mode-mon-col" = 3;
            "weeks-pos" = "right";
            "on-scroll" = 1;
            format = {
              months = "<b>{}</b>";
              days = "<b>{}</b>";
              weeks = "<b>W{:%V}</b>";
              weekdays = "<b>{}</b>";
              today = "<b><u>{}</u></b>";
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
          format = "{icon}  {percent}%";
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
          "icon-size" = 17;
          spacing = 8;
        };
      }
    ];

    style = ''
      @import url("file://${config.home.homeDirectory}/.config/eros/active/theme/waybar.css");
    '';
  };
}
