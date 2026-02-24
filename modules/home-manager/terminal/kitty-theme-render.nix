{}: theme: let
  c = theme.palette;
in ''
  foreground ${c."text-primary"}
  background ${c.background}
  selection_foreground ${c."text-on-accent"}
  selection_background ${c.accent}
  cursor ${c."text-primary"}
  cursor_text_color ${c.background}

  color0 ${c."surface-alt"}
  color8 ${c."text-disabled"}
  color1 ${c.error}
  color9 ${c.error}
  color2 ${c.success}
  color10 ${c.success}
  color3 ${c.warning}
  color11 ${c.warning}
  color4 ${c.accent}
  color12 ${c."accent-hover"}
  color5 ${c.info}
  color13 ${c."accent-muted"}
  color6 ${c.info}
  color14 ${c."text-secondary"}
  color7 ${c."text-primary"}
  color15 ${c."text-primary"}
''
