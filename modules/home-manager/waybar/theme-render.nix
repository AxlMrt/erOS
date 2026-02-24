{config}: theme: let
  c = theme.palette;
  spacing =
    theme.ui.spacing or {
      xs = config.eros.ui.spacing.base;
      sm = config.eros.ui.spacing.base * 2;
      md = config.eros.ui.spacing.base * 3;
      lg = config.eros.ui.spacing.base * 4;
      xl = config.eros.ui.spacing.base * 5;
    };
  radius =
    theme.ui.radius or {
      sm = config.eros.ui.spacing.base;
      md = config.eros.ui.spacing.base * 2;
      lg = config.eros.ui.spacing.base * 3;
    };
in ''
  * {
    font-family: "${theme.fonts.ui}", "${theme.fonts.mono}";
    font-size: ${toString theme.fonts.size}pt;
    font-weight: 500;
    min-height: 0;
  }

  window#waybar {
    background: transparent;
    color: ${c."text-primary"};
  }

  .modules-left,
  .modules-center,
  .modules-right {
    margin: ${toString spacing.xs}px 0 0;
    padding: ${toString spacing.xs}px;
    border-radius: ${toString radius.md}px;
    border: 1px solid ${c.border};
    background: alpha(${c."surface-elevated"}, ${toString (theme.waybar.opacity or 0.85)});
  }

  #group-app_drawer,
  #group-notify,
  #group-laptop,
  #group-mobo_drawer,
  #group-audio,
  #group-status {
    margin: 0 ${toString spacing.xs}px 0 0;
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
  #custom-wifi_status,
  #custom-theme_switch,
  #custom-wallpaper_switch {
    margin: 0;
    padding: ${toString spacing.xs}px;
    border-radius: ${toString radius.sm}px;
    border: 1px solid transparent;
    color: ${c."text-secondary"};
    background: transparent;
    transition: background-color 120ms ease, color 120ms ease, border-color 120ms ease;
  }

  #backlight:hover,
  #battery:hover,
  #clock:hover,
  #cpu:hover,
  #memory:hover,
  #network:hover,
  #pulseaudio:hover,
  #tray:hover,
  #window:hover,
  #workspaces:hover,
  #idle_inhibitor:hover,
  #custom-menu:hover,
  #custom-power:hover,
  #custom-swaync:hover,
  #custom-playerctl:hover,
  #custom-tty:hover,
  #custom-cpu_temp:hover,
  #custom-wifi_status:hover,
  #custom-theme_switch:hover,
  #custom-wallpaper_switch:hover {
    background: alpha(${c."accent-subtle"}, 0.8);
    border-color: ${c."accent-muted"};
    color: ${c."text-primary"};
  }

  #custom-theme_switch,
  #custom-wallpaper_switch,
  #custom-menu,
  #custom-tty {
    color: ${c.accent};
  }

  #group-status {
    margin-right: 0;
  }

  #clock,
  #workspaces,
  #tray,
  #custom-swaync {
    color: ${c."text-primary"};
  }

  #cpu,
  #pulseaudio,
  #battery {
    color: ${c.success};
  }

  #custom-power {
    color: ${c.error};
  }

  #memory,
  #backlight,
  #custom-playerctl,
  #custom-wifi_status,
  #network,
  #window,
  #idle_inhibitor {
    color: ${c."text-muted"};
  }

  #workspaces {
    padding: 0;
  }

  #workspaces button {
    box-shadow: none;
    text-shadow: none;
    margin: 0;
    padding: ${toString spacing.xs}px;
    border-radius: ${toString radius.sm}px;
    border: 1px solid transparent;
    color: ${c."text-secondary"};
    background: transparent;
    transition: background-color 120ms ease, color 120ms ease, border-color 120ms ease;
  }

  #workspaces button * {
    color: ${c."text-secondary"};
  }

  #workspaces button:hover {
    background: alpha(${c."accent-subtle"}, 0.85);
    border-color: ${c."accent-muted"};
    color: ${c."text-primary"};
  }

  #workspaces button:hover * {
    color: ${c."text-primary"};
  }

  #workspaces button.active {
    background: ${c.accent};
    border-color: ${c."accent-hover"};
    color: ${c."text-on-accent"};
    font-weight: 600;
  }

  #workspaces button.active * {
    color: ${c."text-on-accent"};
  }

  #workspaces button.urgent {
    background: alpha(${c.error}, 0.18);
    border-color: ${c.error};
    color: ${c.error};
  }

  #battery.warning {
    color: ${c.warning};
  }

  #battery.critical:not(.charging) {
    background: alpha(${c.error}, 0.18);
    border-color: ${c.error};
    color: ${c.error};
  }

  #network.disconnected,
  #network.disabled,
  #custom-wifi_status.disconnected {
    background: alpha(${c.error}, 0.18);
    border-color: ${c.error};
    color: ${c.error};
  }

  tooltip {
    border-radius: ${toString radius.sm}px;
    border: 1px solid ${c.border};
    background: ${c."surface-elevated"};
    color: ${c."text-primary"};
    padding: ${toString spacing.xs}px;
  }
''
