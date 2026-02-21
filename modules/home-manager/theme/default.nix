{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkOption mkIf types mapAttrs filterAttrs;

  imagePattern = ".*\\.(png|jpg|jpeg|webp|avif|bmp|tiff|gif)$";

  isWallpaperFile = name: fileType:
    (fileType == "regular" || fileType == "symlink")
    && builtins.match imagePattern (lib.toLower name) != null;

  wallpapersFromDir = dir: let
    entries = builtins.readDir dir;
    validEntries = filterAttrs isWallpaperFile entries;
    names = builtins.sort builtins.lessThan (builtins.attrNames validEntries);
  in
    map (name: dir + "/${name}") names;

  baseThemes = {
    nord-night = {
      kind = "dark";
      wallpaper = null;
      wallpaperDir = ../../../wallpapers/minimalist;
      wallpapers = [];
      vscodeTheme = "Default Dark Modern";
      vscodeIconTheme = "vs-seti";
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
    };

    nord-snow = {
      kind = "light";
      wallpaper = null;
      wallpaperDir = null;
      wallpapers = [];
      vscodeTheme = "Default Light+";
      vscodeIconTheme = "vs-seti";
      palette = {
        bg = "#eceff4";
        bgAlt = "#e5e9f0";
        surface = "#d8dee9";
        border = "#4c566a";
        fg = "#2e3440";
        fgMuted = "#434c5e";
        accent = "#5e81ac";
        ok = "#a3be8c";
        warn = "#d08770";
        error = "#bf616a";
      };
    };
  };

  mergedThemes = baseThemes // config.eros.theme.themes;

  resolvedThemes = mapAttrs (_: theme: let
    dirWallpapers =
      if theme.wallpaperDir == null || !builtins.pathExists theme.wallpaperDir
      then []
      else wallpapersFromDir theme.wallpaperDir;
    allWallpapers =
      if theme.wallpapers != []
      then theme.wallpapers
      else dirWallpapers;
  in
    theme
    // {
      wallpapers = allWallpapers;
      wallpaper =
        if theme.wallpaper != null
        then theme.wallpaper
        else if allWallpapers == []
        then null
        else builtins.head allWallpapers;
    })
  mergedThemes;

  selectedTheme = resolvedThemes.${config.eros.theme.variant};

  withCompatPalette = mapAttrs (_name: theme: let
    p = theme.palette;
  in
    theme
    // {
      palette =
        p
        // {
          base = p.bg;
          mantle = p.bgAlt;
          crust = p.bg;
          surface0 = p.surface;
          surface1 = p.surface;
          surface2 = p.border;
          overlay0 = p.border;
          overlay1 = p.fgMuted;
          overlay2 = p.fgMuted;
          text = p.fg;
          subtext0 = p.fgMuted;
          subtext1 = p.fgMuted;
          blue = p.accent;
          green = p.ok;
          yellow = p.warn;
          red = p.error;
          rosewater = p.fg;
          lavender = p.accent;
          mauve = p.accent;
          teal = p.accent;
          peach = p.warn;
          pink = p.accent;
        };
    })
  resolvedThemes;

  activeWallpapers = selectedTheme.wallpapers;
  activeWallpaper =
    if selectedTheme.wallpaper == null
    then ""
    else toString selectedTheme.wallpaper;

  wallpaperListText =
    if activeWallpapers == []
    then ""
    else lib.concatStringsSep "\n" (map toString activeWallpapers) + "\n";
in {
  options = {
    eros.ui = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable shared UI design-system tokens.";
      };

      density = mkOption {
        type = types.enum ["compact" "cozy"];
        default = "compact";
        description = "Global UI density preset.";
      };

      radius = mkOption {
        type = types.int;
        default = 6;
        description = "Global corner radius token.";
      };

      gap = mkOption {
        type = types.int;
        default = 8;
        description = "Global spacing token in px.";
      };

      fonts = {
        ui = mkOption {
          type = types.str;
          default = "Inter";
          description = "UI font family.";
        };

        mono = mkOption {
          type = types.str;
          default = "JetBrainsMono Nerd Font";
          description = "Monospace font family.";
        };

        size = mkOption {
          type = types.int;
          default = 11;
          description = "Default UI/terminal font size.";
        };
      };
    };

    eros.theme = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable global theme registry.";
      };

      variant = mkOption {
        type = types.str;
        default = "nord-night";
        description = "Active theme key for the desktop session.";
      };

      themes = mkOption {
        type = types.attrsOf (types.submodule ({...}: {
          options = {
            kind = mkOption {
              type = types.enum ["light" "dark"];
              default = "dark";
            };

            wallpaper = mkOption {
              type = types.nullOr types.path;
              default = null;
            };

            wallpaperDir = mkOption {
              type = types.nullOr types.path;
              default = null;
            };

            wallpapers = mkOption {
              type = types.listOf types.path;
              default = [];
            };

            vscodeTheme = mkOption {
              type = types.str;
              default = "Default Dark+";
            };

            vscodeIconTheme = mkOption {
              type = types.str;
              default = "vs-seti";
            };

            palette = mkOption {
              type = types.attrsOf types.str;
              default = {};
            };
          };
        }));
        default = {};
        description = "Custom themes merged with built-in minimal themes.";
      };

      registry = mkOption {
        type = types.attrsOf types.anything;
        default = withCompatPalette;
        readOnly = true;
      };

      active = mkOption {
        type = types.attrsOf types.anything;
        default = withCompatPalette.${config.eros.theme.variant};
        readOnly = true;
      };
    };
  };

  config = mkIf config.eros.theme.enable {
    assertions = [
      {
        assertion = builtins.hasAttr config.eros.theme.variant withCompatPalette;
        message = "eros.theme.variant='${config.eros.theme.variant}' is undefined.";
      }
    ];

    home.file.".config/eros/theme-wallpapers.txt".text = wallpaperListText;

    home.packages = [
      (pkgs.writeShellScriptBin "eros-wallpaper-apply" ''
        set -euo pipefail

        wallpaper="''${1:-}"
        list_file="$HOME/.config/eros/theme-wallpapers.txt"

        if [ -z "$wallpaper" ] && [ -f "$list_file" ] && [ -s "$list_file" ]; then
          wallpaper=$(shuf -n 1 "$list_file")
        fi

        if [ -z "$wallpaper" ]; then
          wallpaper='${activeWallpaper}'
        fi

        if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
          echo "eros-wallpaper-apply: no valid wallpaper found" >&2
          exit 0
        fi

        if ! command -v swww >/dev/null 2>&1 || ! command -v swww-daemon >/dev/null 2>&1; then
          exit 0
        fi

        if ! swww query >/dev/null 2>&1; then
          swww-daemon >/dev/null 2>&1 &
          disown || true
          for _ in $(seq 1 30); do
            if swww query >/dev/null 2>&1; then
              break
            fi
            sleep 0.1
          done
        fi

        swww img "$wallpaper" --resize crop
      '')
    ];

    home.sessionVariables = {
      EROS_UI_DENSITY = config.eros.ui.density;
      EROS_THEME_VARIANT = config.eros.theme.variant;
    };
  };
}
