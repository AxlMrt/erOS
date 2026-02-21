{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkOption mkIf types mapAttrs filterAttrs mapAttrs';

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

  baseThemes = import ./themes;

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
    fonts = {
      ui = theme.fonts.ui or config.eros.ui.fonts.ui;
      mono = theme.fonts.mono or config.eros.ui.fonts.mono;
      size = theme.fonts.size or config.eros.ui.fonts.size;
    };
    cursor = {
      name = theme.cursor.name or "Bibata-Modern-Classic";
      size = theme.cursor.size or 24;
    };
    gtk = {
      theme = theme.gtk.theme or "Adwaita";
      iconTheme = theme.gtk.iconTheme or "Papirus";
    };
    qt = {
      platformTheme = theme.qt.platformTheme or "qt6ct";
      style = theme.qt.style or "Adwaita-Dark";
    };
    terminal = {
      opacity = theme.terminal.opacity or 0.84;
    };
    waybar = {
      opacity = theme.waybar.opacity or 0.82;
    };
    vscode = {
      theme = theme.vscode.theme or "Default Dark Modern";
      iconTheme = theme.vscode.iconTheme or "vs-seti";
    };
    defaultWallpaper =
      if theme.defaultWallpaper != null
      then theme.defaultWallpaper
      else if allWallpapers == []
      then null
      else builtins.head allWallpapers;
  in
    theme
    // {
      inherit fonts cursor gtk qt terminal waybar vscode defaultWallpaper;
      wallpapers = allWallpapers;
      wallpaper =
        if defaultWallpaper == null
        then null
        else defaultWallpaper;
    })
  mergedThemes;

  selectedTheme = withCompatPalette.${config.eros.theme.variant};
  themeNames = builtins.attrNames withCompatPalette;

  wallpaperListText = theme:
    if theme.wallpapers == []
    then ""
    else lib.concatStringsSep "\n" (map toString theme.wallpapers) + "\n";

  mkWaybarCss = import ../waybar/theme-render.nix {inherit config;};
  mkRofiTheme = import ../launcher/rofi-theme-render.nix {inherit config;};
  mkSwayncCss = import ../notifications/swaync-theme-render.nix {inherit config;};
  mkKittyConf = import ../terminal/kitty-theme-render.nix {};
  mkStarshipToml = import ../shell/starship-theme-render.nix {};
  mkHyprlandTheme = import ../desktop-user/hyprland-theme-render.nix {};

  mkColorEnv = theme: let
    c = theme.palette;
  in ''
    export EROS_COLOR_BG='${c.bg}'
    export EROS_COLOR_BG_ALT='${c.bgAlt}'
    export EROS_COLOR_SURFACE='${c.surface}'
    export EROS_COLOR_BORDER='${c.border}'
    export EROS_COLOR_FG='${c.fg}'
    export EROS_COLOR_FG_MUTED='${c.fgMuted}'
    export EROS_COLOR_ACCENT='${c.accent}'
    export EROS_COLOR_OK='${c.ok}'
    export EROS_COLOR_WARN='${c.warn}'
    export EROS_COLOR_ERROR='${c.error}'
  '';

  mkSettingsEnv = theme: ''
    export EROS_THEME_KIND='${theme.kind}'
    export EROS_GTK_THEME='${theme.gtk.theme}'
    export EROS_ICON_THEME='${theme.gtk.iconTheme}'
    export EROS_CURSOR_THEME='${theme.cursor.name}'
    export EROS_CURSOR_SIZE='${toString theme.cursor.size}'
    export EROS_QT_PLATFORM_THEME='${theme.qt.platformTheme}'
    export EROS_QT_STYLE='${theme.qt.style}'
    export EROS_FONT_UI='${theme.fonts.ui}'
    export EROS_FONT_MONO='${theme.fonts.mono}'
    export EROS_FONT_SIZE='${toString theme.fonts.size}'
  '';

  mkThemeArtifacts = name: theme:
    pkgs.runCommandLocal "eros-theme-${name}" {} ''
      mkdir -p "$out"
      cat > "$out/waybar.css" <<'EOF'
      ${mkWaybarCss theme}
      EOF
      cat > "$out/rofi.rasi" <<'EOF'
      ${mkRofiTheme theme}
      EOF
      cat > "$out/swaync.css" <<'EOF'
      ${mkSwayncCss theme}
      EOF
      cat > "$out/kitty.conf" <<'EOF'
      ${mkKittyConf theme}
      EOF
      cat > "$out/starship.toml" <<'EOF'
      ${mkStarshipToml theme}
      EOF
      cat > "$out/hyprland-theme.conf" <<'EOF'
      ${mkHyprlandTheme theme}
      EOF
      cat > "$out/colors.env" <<'EOF'
      ${mkColorEnv theme}
      EOF
      cat > "$out/settings.env" <<'EOF'
      ${mkSettingsEnv theme}
      EOF
      cat > "$out/wallpapers.txt" <<'EOF'
      ${wallpaperListText theme}
      EOF
      cat > "$out/default-wallpaper.txt" <<'EOF'
      ${
        if theme.defaultWallpaper == null
        then ""
        else toString theme.defaultWallpaper
      }
      EOF
    '';

  themeArtifacts = mapAttrs mkThemeArtifacts withCompatPalette;

  themeListText = lib.concatStringsSep "\n" themeNames + "\n";
  themeListFile = pkgs.writeText "eros-themes.txt" themeListText;

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

  themePathCases = lib.concatMapStringsSep "\n" (name: "    ${name}) echo ${lib.escapeShellArg (toString themeArtifacts.${name})} ;;") themeNames;

  themectlScript =
    lib.replaceStrings
    ["@DEFAULT_THEME@" "@THEME_CASES@" "@THEME_LIST_FILE@" "@WAYBAR_BIN@"]
    [
      (lib.escapeShellArg config.eros.theme.variant)
      themePathCases
      (lib.escapeShellArg (toString themeListFile))
      (lib.escapeShellArg "${pkgs.waybar}/bin/waybar")
    ]
    (builtins.readFile ./scripts/eros-themectl.sh);

  themectl = pkgs.writeShellScriptBin "eros-themectl" themectlScript;
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

            wallpaperDir = mkOption {
              type = types.nullOr types.path;
              default = null;
            };

            wallpapers = mkOption {
              type = types.listOf types.path;
              default = [];
            };

            defaultWallpaper = mkOption {
              type = types.nullOr types.path;
              default = null;
            };

            fonts = mkOption {
              type = types.attrsOf types.anything;
              default = {};
            };

            cursor = mkOption {
              type = types.attrsOf types.anything;
              default = {};
            };

            gtk = mkOption {
              type = types.attrsOf types.anything;
              default = {};
            };

            qt = mkOption {
              type = types.attrsOf types.anything;
              default = {};
            };

            terminal = mkOption {
              type = types.attrsOf types.anything;
              default = {};
            };

            waybar = mkOption {
              type = types.attrsOf types.anything;
              default = {};
            };

            vscode = mkOption {
              type = types.attrsOf types.anything;
              default = {};
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

      available = mkOption {
        type = types.listOf types.str;
        default = themeNames;
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

    home.file.".config/eros/themes.txt".text = themeListText;

    home.packages = [
      themectl
    ];

    home.activation.erosThemeInit = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD ${lib.getExe themectl} init >/dev/null 2>&1 || true
    '';

    home.sessionVariables = {
      EROS_UI_DENSITY = config.eros.ui.density;
      EROS_THEME_VARIANT = config.eros.theme.variant;
      EROS_THEME_ACTIVE_DIR = "$HOME/.config/eros/active/theme";
      GTK_THEME = selectedTheme.gtk.theme;
      QT_QPA_PLATFORMTHEME = selectedTheme.qt.platformTheme;
      QT_STYLE_OVERRIDE = selectedTheme.qt.style;
      XCURSOR_THEME = selectedTheme.cursor.name;
      XCURSOR_SIZE = toString selectedTheme.cursor.size;
    };

    xdg.configFile =
      mapAttrs' (name: path: {
        name = "eros/themes/${name}";
        value.source = path;
      })
      themeArtifacts;
  };
}
