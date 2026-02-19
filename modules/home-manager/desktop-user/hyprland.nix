{...}: {
  # User session behavior for Hyprland.
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";

      exec-once = [
        "qs-wallpapers-apply"
        "waybar"
      ];

      monitor = ",preferred,auto,1";

      input = {
        kb_layout = "fr";
      };

      bind = [
        "$mod, F, exec, firefox"
        "$mod, T, exec, kitty"
        "$mod, D, exec, rofi -show drun"
        "$mod, Q, killactive"
        "$mod, E, exit"
      ];
    };
  };
}
