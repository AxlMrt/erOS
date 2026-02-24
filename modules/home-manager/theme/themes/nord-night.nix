{
  kind = "dark";

  wallpaperDir = ../../../../wallpapers/nord-night;
  wallpapers = [];
  defaultWallpaper = ../../../../wallpapers/nord-night/01-default.png;

  palette = {
    background = "#2e3440";
    surface = "#3b4252";
    "surface-alt" = "#434c5e";
    "surface-elevated" = "#4c566a";
    border = "#4c566a";
    accent = "#88c0d0";
    "accent-hover" = "#8fbcbb";
    "accent-muted" = "#81a1c1";
    "accent-subtle" = "#3f4b5b";
    success = "#a3be8c";
    warning = "#ebcb8b";
    error = "#bf616a";
    info = "#81a1c1";
    "text-primary" = "#eceff4";
    "text-secondary" = "#e5e9f0";
    "text-muted" = "#d8dee9";
    "text-on-accent" = "#2e3440";
    "text-disabled" = "#94a0b5";
  };

  fonts = {
    ui = "Inter";
    mono = "JetBrainsMono Nerd Font";
    size = 11;
  };

  cursor = {
    name = "Nordzy-catppuccin-frappe-blue";
    size = 20;
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
