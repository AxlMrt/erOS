{config}: theme: let
  c = theme.palette;
  opacity = toString (theme.waybar.opacity or 0.82);
  radius = toString config.eros.ui.radius;
in ''
  * {
    font-family: "${theme.fonts.mono}";
    font-weight: bold;
    min-height: 0;
    font-size: 97%;
  }

  window#waybar {
    transition-property: background-color;
    transition-duration: 0.3s;
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
    background: alpha(${c.bg}, ${opacity});
    border: 1px solid alpha(${c.border}, 0.74);
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
  #custom-wifi_status,
  #custom-theme_switch,
  #custom-wallpaper_switch {
    padding: 3px 6px;
  }

  #custom-menu,
  #custom-theme_switch,
  #custom-wallpaper_switch { color: ${c.accent}; }
  #custom-power { color: ${c.error}; }
  #custom-swaync { color: ${c.accent}; }
  #custom-playerctl { color: ${c.fgMuted}; }
  #custom-wifi_status,
  #network { color: ${c.accent}; }
  #clock,
  #window,
  #tray { color: ${c.fg}; }
  #cpu,
  #pulseaudio,
  #battery { color: ${c.ok}; }
  #memory,
  #backlight,
  #idle_inhibitor { color: ${c.fgMuted}; }

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
    border-radius: ${radius}px;
    border: 1px solid alpha(${c.border}, 0.8);
    background: alpha(${c.bg}, 0.94);
    color: ${c.fg};
  }
''
