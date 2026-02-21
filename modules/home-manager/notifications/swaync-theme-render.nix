{config}: theme: let
  c = theme.palette;
in ''
  * {
    font-family: "${theme.fonts.ui}", "${theme.fonts.mono}";
    font-size: ${toString theme.fonts.size}pt;
  }

  .notification,
  .control-center {
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
''
