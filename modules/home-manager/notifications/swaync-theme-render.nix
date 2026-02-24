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
  }

  .notification,
  .control-center {
    background: ${c."surface-elevated"};
    color: ${c."text-primary"};
    border: 1px solid ${c.border};
    border-radius: ${toString radius.md}px;
  }

  .notification {
    padding: ${toString spacing.xs}px;
    margin: ${toString spacing.xs}px ${toString spacing.xs}px 0 ${toString spacing.xs}px;
  }

  .control-center {
    padding: ${toString spacing.sm}px;
  }

  .notification-default-action,
  .notification-action {
    border-radius: ${toString radius.sm}px;
    background: ${c."surface-alt"};
    color: ${c."text-primary"};
    border: 1px solid ${c.border};
    padding: ${toString spacing.xs}px;
  }

  .notification-action:hover,
  .notification-default-action:hover {
    background: ${c."accent-subtle"};
    border-color: ${c.accent};
  }

  .close-button {
    background: ${c.error};
    color: ${c."text-on-accent"};
    border-radius: 999px;
  }

  .notification.critical {
    border-color: ${c.error};
    background: alpha(${c.error}, 0.16);
  }

  .notification-content,
  .summary,
  .body,
  .widget-title,
  .widget-label {
    color: ${c."text-primary"};
  }

  .time,
  .floating-notifications .notification .body,
  .control-center .notification .body {
    color: ${c."text-secondary"};
  }

  .widget-title,
  .widget-mpris,
  .widget-volume,
  .widget-backlight,
  .widget-dnd,
  .widget-buttons-grid {
    border-radius: ${toString radius.sm}px;
    border: 1px solid ${c.border};
    background: ${c."surface-alt"};
    padding: ${toString spacing.xs}px;
  }
''
