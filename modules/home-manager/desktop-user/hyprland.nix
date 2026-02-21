{config, ...}: let
  p = config.eros.theme.active.palette;
in {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      monitor = ",preferred,auto,1";

      exec-once = [
        "eros-wallpaper-apply"
        "waybar"
        "swaync"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      general = {
        gaps_in = config.eros.ui.gap;
        gaps_out = config.eros.ui.gap;
        border_size = 1;
        "col.active_border" = "rgb(${builtins.substring 1 6 p.accent})";
        "col.inactive_border" = "rgb(${builtins.substring 1 6 p.border})";
        layout = "dwindle";
      };

      decoration = {
        rounding = config.eros.ui.radius;
        blur.enabled = false;
        shadow.enabled = false;
      };

      animations = {
        enabled = false;
      };

      input = {
        kb_layout = "fr";
        follow_mouse = 1;
        touchpad.natural_scroll = true;
      };

      bind = [
        "$mod, T, exec, kitty"
        "$mod, D, exec, rofi -show drun"
        "$mod SHIFT, D, exec, rofi -show run"
        "$mod, F, exec, firefox"
        "$mod, N, exec, swaync-client -t"
        "$mod, C, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
        "$mod, Q, killactive"
        "$mod SHIFT, Q, exit"
        "$mod, Return, fullscreen, 1"
        "$mod, V, togglefloating"
        "$mod, H, movefocus, l"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        "$mod, L, movefocus, r"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.3 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl set +10%"
        ",XF86MonBrightnessDown, exec, brightnessctl set 10%-"
      ];

      windowrule = [
        "suppress_event maximize, match:class .*"
      ];
    };
  };
}
