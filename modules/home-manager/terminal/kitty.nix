{config, ...}: let
  t = config.eros.theme.active;
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
      background_opacity = t.terminal.opacity;
      dynamic_background_opacity = false;
      cursor_shape = "block";
      linux_display_server = "wayland";
      allow_remote_control = true;
    };

    extraConfig = ''
      include ~/.config/eros/active/theme/kitty.conf

      map ctrl+shift+v paste_from_clipboard
      map ctrl+shift+c copy_to_clipboard
      map ctrl+shift+enter new_window_with_cwd
      map ctrl+shift+t new_tab
      map ctrl+shift+q close_tab
    '';
  };
}
