{
  config,
  pkgs,
  ...
}: let
  inherit (config.lib.formats.rasi) mkLiteral;
  c = config.eros.theme.active.palette;
in {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    terminal = "kitty";
    location = "center";
    extraConfig = {
      show = "drun";
      modi = "drun";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      display-drun = "";
      drun-display-format = "{name}";
      normal-window = true;
      sort = false;
      sorting-method = "fzf";
      case-sensitive = true;
      parse-hosts = false;
      parse-known-hosts = false;
      cycle = false;
      hide-scrollbar = true;
      columns = 2;
      no-actions = true;
      hover-select = true;
      click-to-exit = true;
      me-select-entry = "MouseSecondary";
      me-accept-entry = "MousePrimary";
      kb-expand = "Tab";
      kb-cancel = "Escape";
      filter = "";
      matching = "normal";
      line-wrap = false;
      dpi = 1;
    };

    theme = {
      "*" = {
        font = "JetBrainsMono Nerd Font 11";
        background = mkLiteral "${c.bg}cc";
        background-alt = mkLiteral "${c.bgAlt}cc";
        foreground = mkLiteral c.fg;
        foreground-alt = mkLiteral c.fgMuted;
        text-color = mkLiteral c.fg;
        border-color = mkLiteral c.border;
        selected = mkLiteral c.accent;
        active = mkLiteral c.accent;
        urgent = mkLiteral c.error;
        text-selected = mkLiteral c.bg;
      };

      window = {
        transparency = "real";
        location = mkLiteral "center";
        anchor = mkLiteral "center";
        fullscreen = false;
        width = mkLiteral "30%";
        height = mkLiteral "30%";
        x-offset = 0;
        y-offset = 0;
        margin = 0;
        padding = 0;
        border = 0;
        border-radius = 8;
        background-color = mkLiteral "${c.bg}cc";
      };

      mainbox = {
        spacing = 0;
        margin = 0;
        padding = 10;
        border = 0;
        border-radius = 0;
        background-color = mkLiteral "transparent";
        orientation = mkLiteral "vertical";
        children = map mkLiteral ["inputbar" "listbox"];
      };

      inputbar = {
        spacing = 8;
        margin = 0;
        padding = mkLiteral "6px";
        border = 0;
        border-radius = 10;
        border-color = mkLiteral c.border;
        background-color = mkLiteral "${c.bgAlt}cc";
        text-color = mkLiteral c.fgMuted;
        children = map mkLiteral ["prompt" "entry"];
      };

      prompt = {
        text-color = mkLiteral "@foreground-alt";
        background-color = mkLiteral "transparent";
        padding = mkLiteral "0px 12px 0px 4px";
        vertical-align = mkLiteral "0.5";
      };

      entry = {
        font = "JetBrainsMono Nerd Font 11";
        expand = false;
        width = mkLiteral "100%";
        padding = mkLiteral "3px 8px";
        border-radius = 10;
        border = 1;
        border-color = mkLiteral c.border;
        background-color = mkLiteral "transparent";
        text-color = mkLiteral c.fg;
        cursor = mkLiteral "text";
        placeholder = "Search";
        placeholder-color = mkLiteral "@foreground-alt";
      };

      listbox = {
        spacing = 0;
        padding = 0;
        background-color = mkLiteral "transparent";
        orientation = mkLiteral "vertical";
        children = map mkLiteral ["listview"];
      };

      message = {
        background-color = mkLiteral "transparent";
        border = 0;
      };

      listview = {
        columns = 2;
        lines = 5;
        cycle = false;
        dynamic = false;
        scrollbar = false;
        layout = mkLiteral "vertical";
        reverse = false;
        fixed-height = false;
        fixed-columns = true;
        spacing = 4;
        margin = mkLiteral "10px 0px";
        padding = 0;
        border = 0;
        border-radius = 8;
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@foreground";
      };

      scrollbar = {
        width = 0;
        border = 0;
        handle-color = mkLiteral "@border-color";
        handle-width = 0;
        padding = 0;
        border-radius = 0;
      };

      element = {
        spacing = 10;
        margin = 0;
        padding = 3;
        border = 0;
        border-radius = 8;
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@foreground";
        cursor = mkLiteral "pointer";
      };

      "element normal.normal" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral c.fg;
      };

      "element normal.urgent" = {
        background-color = mkLiteral "@urgent";
        text-color = mkLiteral "@foreground";
      };

      "element normal.active" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@foreground";
      };

      "element selected.normal" = {
        background-color = mkLiteral "${c.bg}cc";
        border = 1;
        border-color = mkLiteral c.border;
        border-radius = 10;
        text-color = mkLiteral c.fg;
      };

      "element selected.urgent" = {
        background-color = mkLiteral c.error;
        text-color = mkLiteral c.fg;
      };

      "element selected.active" = {
        background-color = mkLiteral "${c.bg}cc";
        border = 1;
        border-color = mkLiteral c.border;
        border-radius = 10;
        text-color = mkLiteral c.fg;
      };

      "element alternate.normal" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral c.fg;
      };

      "element alternate.active" = {
        background-color = mkLiteral c.surface;
        text-color = mkLiteral c.fg;
      };

      "element alternate.urgent" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral c.fg;
      };

      element-icon = {
        size = 24;
        padding = mkLiteral "0px 5px 0px 0px";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
      };

      element-text = {
        font = "JetBrainsMono Nerd Font 11";
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "inherit";
        vertical-align = mkLiteral "0.5";
        horizontal-align = mkLiteral "0.0";
      };

      "element-text selected" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral c.fg;
      };

      mode-switcher = {
        spacing = 6;
        margin = 0;
        padding = 0;
        background-color = mkLiteral "transparent";
      };

      button = {
        width = mkLiteral "4%";
        padding = 0;
        border-radius = 7;
        border = 1;
        border-color = mkLiteral "@border-color";
        background-color = mkLiteral c.bgAlt;
        text-color = mkLiteral c.fg;
      };

      "button selected" = {
        background-color = mkLiteral "@active";
        text-color = mkLiteral c.bg;
      };
    };
  };
}
