{config, ...}: let
  c = config.eros.theme.active.palette;
in {
  programs.kitty = {
    enable = true;
    settings = {
      font_family = config.eros.ui.fonts.mono;
      font_size = config.eros.ui.fonts.size;
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      wheel_scroll_min_lines = 1;
      scrollback_lines = 10000;
      window_padding_width = 8;
      background_opacity = 0.8;
      dynamic_background_opacity = false;
      cursor_shape = "block";
      linux_display_server = "wayland";
    };

    extraConfig = ''
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

      map ctrl+shift+v paste_from_clipboard
      map ctrl+shift+c copy_to_clipboard
      map ctrl+shift+enter new_window_with_cwd
      map ctrl+shift+t new_tab
      map ctrl+shift+q close_tab
    '';
  };
}
