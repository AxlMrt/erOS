{}: theme: let
  c = theme.palette;
in ''
  add_newline = false
  format = "$directory$git_branch$git_status$cmd_duration$line_break$character"

  [character]
  success_symbol = "[❯](bold ${c.success})"
  error_symbol = "[❯](bold ${c.error})"

  [directory]
  style = "bold ${c.accent}"

  [git_branch]
  style = "${c."text-secondary"}"

  [git_status]
  style = "${c.warning}"

  [cmd_duration]
  min_time = 500
  show_milliseconds = false
  style = "${c."text-muted"}"
''
