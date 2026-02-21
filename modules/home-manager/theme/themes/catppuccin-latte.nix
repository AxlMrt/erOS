{
  kind = "light";

  wallpaperDir = ../../../../wallpapers/catppuccin/latte;
  wallpapers = [];
  defaultWallpaper = null;

  palette = {
    bg = "#eff1f5";
    bgAlt = "#e6e9ef";
    surface = "#ccd0da";
    border = "#bcc0cc";
    fg = "#4c4f69";
    fgMuted = "#6c6f85";
    accent = "#1e66f5";
    ok = "#40a02b";
    warn = "#df8e1d";
    error = "#d20f39";
  };

  fonts = {
    ui = "Inter";
    mono = "JetBrainsMono Nerd Font";
    size = 11;
  };

  cursor = {
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  gtk = {
    theme = "Adwaita";
    iconTheme = "Papirus";
  };

  qt = {
    platformTheme = "qt6ct";
    style = "Adwaita-Dark";
  };

  terminal = {
    opacity = 0.88;
  };

  waybar = {
    opacity = 0.84;
  };

  vscode = {
    theme = "Catppuccin Latte";
    iconTheme = "catppuccin-latte";
  };
}
