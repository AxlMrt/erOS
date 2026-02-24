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
      size = theme.cursor.size or 20;
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
      opacity = theme.terminal.opacity or 0.85;
    };
    waybar = {
      opacity = theme.waybar.opacity or 0.85;
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
    palette = let
      p = theme.palette;
      background = p.background or "#111111";
      surface = p.surface or background;
      surfaceAlt = p."surface-alt" or surface;
      surfaceElevated = p."surface-elevated" or surfaceAlt;
      border = p.border or surface;
      accent = p.accent or "#3b82f6";
      accentHover = p."accent-hover" or accent;
      accentMuted = p."accent-muted" or accent;
      accentSubtle = p."accent-subtle" or surfaceAlt;
      success = p.success or "#22c55e";
      warning = p.warning or "#f59e0b";
      error = p.error or "#ef4444";
      info = p.info or accent;
      textPrimary = p."text-primary" or "#f5f5f5";
      textSecondary = p."text-secondary" or textPrimary;
      textMuted = p."text-muted" or textSecondary;
      textOnAccent = p."text-on-accent" or "#ffffff";
      textDisabled = p."text-disabled" or textMuted;
    in
      p
      // {
        background = background;
        surface = surface;
        "surface-alt" = surfaceAlt;
        "surface-elevated" = surfaceElevated;
        border = border;
        accent = accent;
        "accent-hover" = accentHover;
        "accent-muted" = accentMuted;
        "accent-subtle" = accentSubtle;
        success = success;
        warning = warning;
        error = error;
        info = info;
        "text-primary" = textPrimary;
        "text-secondary" = textSecondary;
        "text-muted" = textMuted;
        "text-on-accent" = textOnAccent;
        "text-disabled" = textDisabled;
      };
  in
    theme
    // {
      inherit fonts cursor gtk qt terminal waybar vscode defaultWallpaper palette;
      ui = {
        spacing = spacingScale;
        radius = radiusScale;
      };
      wallpapers = allWallpapers;
      wallpaper =
        if defaultWallpaper == null
        then null
        else defaultWallpaper;
    })
  mergedThemes;

  selectedTheme = resolvedThemes.${config.eros.theme.variant};
  themeNames = builtins.attrNames resolvedThemes;

  spacingScale = {
    xs = config.eros.ui.spacing.base;
    sm = config.eros.ui.spacing.base * 2;
    md = config.eros.ui.spacing.base * 3;
    lg = config.eros.ui.spacing.base * 4;
    xl = config.eros.ui.spacing.base * 5;
  };

  radiusScale = {
    sm = config.eros.ui.spacing.base;
    md = config.eros.ui.spacing.base * 2;
    lg = config.eros.ui.spacing.base * 3;
  };

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
    export EROS_COLOR_BACKGROUND='${c.background}'
    export EROS_COLOR_SURFACE='${c.surface}'
    export EROS_COLOR_SURFACE_ALT='${c."surface-alt"}'
    export EROS_COLOR_SURFACE_ELEVATED='${c."surface-elevated"}'
    export EROS_COLOR_BORDER='${c.border}'
    export EROS_COLOR_ACCENT='${c.accent}'
    export EROS_COLOR_ACCENT_HOVER='${c."accent-hover"}'
    export EROS_COLOR_ACCENT_MUTED='${c."accent-muted"}'
    export EROS_COLOR_ACCENT_SUBTLE='${c."accent-subtle"}'
    export EROS_COLOR_SUCCESS='${c.success}'
    export EROS_COLOR_WARNING='${c.warning}'
    export EROS_COLOR_ERROR='${c.error}'
    export EROS_COLOR_INFO='${c.info}'
    export EROS_COLOR_TEXT_PRIMARY='${c."text-primary"}'
    export EROS_COLOR_TEXT_SECONDARY='${c."text-secondary"}'
    export EROS_COLOR_TEXT_MUTED='${c."text-muted"}'
    export EROS_COLOR_TEXT_ON_ACCENT='${c."text-on-accent"}'
    export EROS_COLOR_TEXT_DISABLED='${c."text-disabled"}'
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

  themeArtifacts = mapAttrs mkThemeArtifacts resolvedThemes;
  themeListText = lib.concatStringsSep "\n" themeNames + "\n";
  themeListFile = pkgs.writeText "eros-themes.txt" themeListText;

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
        default = 8;
        description = "Global corner radius token.";
      };

      gap = mkOption {
        type = types.int;
        default = 8;
        description = "Global spacing token in px.";
      };

      spacing.base = mkOption {
        type = types.int;
        default = 8;
        description = "Base spacing unit in px for all UI spacing scales.";
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
        default = resolvedThemes;
        readOnly = true;
      };

      active = mkOption {
        type = types.attrsOf types.anything;
        default = resolvedThemes.${config.eros.theme.variant};
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
        assertion = builtins.hasAttr config.eros.theme.variant resolvedThemes;
        message = "eros.theme.variant='${config.eros.theme.variant}' is undefined.";
      }
    ];

    home.file.".config/eros/themes.txt".text = themeListText;

    home.packages = [
      themectl
      pkgs.nordzy-cursor-theme
      pkgs.bibata-cursors
    ];

    home.activation.erosThemeInit = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD ${lib.getExe themectl} init >/dev/null 2>&1 || true
    '';

    home.sessionVariables = {
      EROS_UI_DENSITY = config.eros.ui.density;
      EROS_UI_SPACING_BASE = toString config.eros.ui.spacing.base;
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
