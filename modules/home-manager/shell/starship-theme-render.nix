{}: theme: let
  c = theme.palette;
in ''
  add_newline = false
  format = "$directory$git_branch$git_status$cmd_duration$line_break$character"

  [character]
  success_symbol = "[❯](bold ${c.ok})"
  error_symbol = "[❯](bold ${c.error})"

  [directory]
  style = "bold ${c.accent}"

  [git_branch]
  style = "bold ${c.fgMuted}"

  [git_status]
  style = "bold ${c.warn}"

  [cmd_duration]
  min_time = 500
  show_milliseconds = false
  style = "${c.fgMuted}"
''
