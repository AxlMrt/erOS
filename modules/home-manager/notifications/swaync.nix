{config, ...}: let
  c = config.eros.theme.active.palette;
in {
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      timeout = 6;
      timeout-low = 3;
      timeout-critical = 0;
      fit-to-screen = true;
      layer = "overlay";
      control-center-width = 380;
      control-center-height = 680;
      notification-window-width = 340;
      keyboard-shortcuts = true;
      image-visibility = "never";
    };

    style = ''
      * {
        font-family: "${config.eros.ui.fonts.ui}", "${config.eros.ui.fonts.mono}";
        font-size: ${toString config.eros.ui.fonts.size}pt;
      }

      .notification, .control-center {
        background: ${c.bgAlt};
        color: ${c.fg};
        border: 1px solid ${c.border};
        border-radius: ${toString config.eros.ui.radius}px;
      }

      .notification-content,
      .summary,
      .body,
      .widget-title,
      .widget-label {
        color: ${c.fg};
      }
    '';
  };
}
