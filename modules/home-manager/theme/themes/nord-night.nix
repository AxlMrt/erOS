{
  kind = "dark";

  wallpaperDir = ../../../../wallpapers/nord-night;
  wallpapers = [];
  defaultWallpaper = ../../../../wallpapers/nord-night/01-default.png;

  palette = {
    bg = "#2e3440";
    bgAlt = "#3b4252";
    surface = "#434c5e";
    border = "#4c566a";
    fg = "#eceff4";
    fgMuted = "#d8dee9";
    accent = "#88c0d0";
    ok = "#a3be8c";
    warn = "#ebcb8b";
    error = "#bf616a";
  };

  fonts = {
    ui = "Inter";
    mono = "JetBrainsMono Nerd Font";
    size = 11;
  };

  cursor = {
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  gtk = {
    theme = "Adwaita-dark";
    iconTheme = "Papirus-Dark";
  };

  qt = {
    platformTheme = "qt6ct";
    style = "Adwaita-Dark";
  };

  terminal = {
    opacity = 0.82;
  };

  waybar = {
    opacity = 0.78;
  };

  vscode = {
    theme = "Default Dark Modern";
    iconTheme = "vs-seti";
  };
}
