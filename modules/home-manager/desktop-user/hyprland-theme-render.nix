{}: theme: let
  c = theme.palette;
in ''
  general {
    col.active_border = rgb(${builtins.substring 1 6 c.accent})
    col.inactive_border = rgb(${builtins.substring 1 6 c.border})
  }
''
