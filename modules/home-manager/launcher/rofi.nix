{pkgs, ...}: {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    terminal = "kitty";
    location = "center";
    extraConfig = {
      show = "drun";
      modi = "drun";
      show-icons = true;
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
  };
}
