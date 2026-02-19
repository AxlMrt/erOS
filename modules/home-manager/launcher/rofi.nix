{
  config,
  pkgs,
  ...
}: let
  c = config.eros.theme.active.palette;
in {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    terminal = "kitty";
    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      icon-theme = "Papirus";
      drun-display-format = "{name}";
      disable-history = false;
      hover-select = true;
    };
    theme = {
      "*" = {
        background = c.base;
        background-alt = c.mantle;
        foreground = c.text;
        selected = c.blue;
        active = c.green;
        urgent = c.red;
      };
      window = {
        background-color = "@background";
        border = 2;
        border-color = "@selected";
        border-radius = 10;
        width = 40;
      };
      inputbar = {
        background-color = "@background-alt";
        text-color = "@foreground";
        padding = 8;
      };
      listview = {
        lines = 10;
        columns = 1;
        fixed-height = false;
      };
      element = {
        padding = 8;
        text-color = "@foreground";
        background-color = "transparent";
      };
      "element selected" = {
        background-color = "@selected";
        text-color = c.crust;
      };
    };
  };
}
