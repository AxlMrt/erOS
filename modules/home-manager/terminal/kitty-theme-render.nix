{}: theme: let
  c = theme.palette;
in ''
  foreground ${c.fg}
  background ${c.bg}
  selection_foreground ${c.bg}
  selection_background ${c.accent}
  cursor ${c.fg}
  cursor_text_color ${c.bg}

  color0 ${c.bgAlt}
  color8 ${c.border}
  color1 ${c.error}
  color9 ${c.warn}
  color2 ${c.ok}
  color10 ${c.ok}
  color3 ${c.warn}
  color11 ${c.warn}
  color4 ${c.accent}
  color12 ${c.fgMuted}
  color5 ${c.fgMuted}
  color13 ${c.accent}
  color6 ${c.accent}
  color14 ${c.fg}
  color7 ${c.fg}
  color15 ${c.fgMuted}
''
