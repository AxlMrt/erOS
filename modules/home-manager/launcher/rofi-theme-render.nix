{config, ...}: theme: let
  c = theme.palette;
  fontFamily = theme.fonts.mono;
  fontSize = toString theme.fonts.size;

  overlayAlpha = "cc";
  borderWidth = 1;

  radiusBase = config.eros.ui.radius;
  radiusWindow = toString (radiusBase + 2);
  radiusInput = toString (radiusBase + 4);
  radiusElement = toString (radiusBase + 2);
  radiusButton = toString (radiusBase + 1);

  spacingCompact = 4;
  spacingNormal = 6;
  spacingWide = 8;
  panelPadding = 10;
in ''
  * {
    font: "${fontFamily} ${fontSize}";
    icon-theme: "${theme.gtk.iconTheme}";
    background: ${c.bg}${overlayAlpha};
    background-alt: ${c.bgAlt}${overlayAlpha};
    foreground: ${c.fg};
    foreground-alt: ${c.fgMuted};
    text-color: ${c.fg};
    border-color: ${c.border};
    selected: ${c.accent};
    active: ${c.accent};
    urgent: ${c.error};
    text-selected: ${c.bg};
  }

  window {
    transparency: "real";
    location: center;
    anchor: center;
    fullscreen: false;
    width: 30%;
    height: 30%;
    x-offset: 0;
    y-offset: 0;
    margin: 0;
    padding: 0;
    border: 0;
    border-radius: ${radiusWindow};
    background-color: ${c.bg}${overlayAlpha};
  }

  mainbox {
    spacing: 0;
    margin: 0;
    padding: ${toString panelPadding}px;
    border: 0;
    border-radius: 0;
    background-color: transparent;
    orientation: vertical;
    children: [ inputbar, listbox ];
  }

  inputbar {
    spacing: ${toString spacingWide}px;
    margin: 0;
    padding: ${toString spacingNormal}px;
    border: 0;
    border-radius: ${radiusInput};
    border-color: ${c.border};
    background-color: ${c.bgAlt}${overlayAlpha};
    text-color: ${c.fgMuted};
    children: [ prompt, entry ];
  }

  prompt {
    text-color: @foreground-alt;
    background-color: transparent;
    padding: 0px 12px 0px 4px;
    vertical-align: 0.5;
  }

  entry {
    font: "${fontFamily} ${fontSize}";
    expand: false;
    width: 100%;
    padding: 3px ${toString spacingWide}px;
    border-radius: ${radiusInput};
    border: ${toString borderWidth}px;
    border-color: ${c.border};
    background-color: transparent;
    text-color: ${c.fg};
    cursor: text;
    placeholder: "Search";
    placeholder-color: @foreground-alt;
  }

  listbox {
    spacing: 0;
    padding: 0;
    background-color: transparent;
    orientation: vertical;
    children: [ listview ];
  }

  message {
    background-color: transparent;
    border: 0;
  }

  listview {
    columns: 2;
    lines: 5;
    cycle: false;
    dynamic: false;
    scrollbar: false;
    layout: vertical;
    reverse: false;
    fixed-height: false;
    fixed-columns: true;
    spacing: ${toString spacingCompact};
    margin: 10px 0px;
    padding: 0;
    border: 0;
    border-radius: ${radiusElement};
    background-color: transparent;
    text-color: @foreground;
  }

  scrollbar {
    width: 0;
    border: 0;
    handle-color: @border-color;
    handle-width: 0;
    padding: 0;
    border-radius: 0;
  }

  element {
    spacing: 10px;
    margin: 0;
    padding: 3;
    border: 0;
    border-radius: ${radiusElement};
    background-color: transparent;
    text-color: @foreground;
    cursor: pointer;
  }

  element normal.normal {
    background-color: transparent;
    text-color: ${c.fg};
  }

  element normal.urgent {
    background-color: @urgent;
    text-color: @foreground;
  }

  element normal.active {
    background-color: transparent;
    text-color: @foreground;
  }

  element selected.normal {
    background-color: ${c.bg}${overlayAlpha};
    border: ${toString borderWidth};
    border-color: ${c.border};
    border-radius: ${radiusInput};
    text-color: ${c.fg};
  }

  element selected.urgent {
    background-color: ${c.error};
    text-color: ${c.fg};
  }

  element selected.active {
    background-color: ${c.bg}${overlayAlpha};
    border: ${toString borderWidth};
    border-color: ${c.border};
    border-radius: ${radiusInput};
    text-color: ${c.fg};
  }

  element alternate.normal {
    background-color: transparent;
    text-color: ${c.fg};
  }

  element alternate.active {
    background-color: ${c.surface};
    text-color: ${c.fg};
  }

  element alternate.urgent {
    background-color: transparent;
    text-color: ${c.fg};
  }

  element-icon {
    size: 24;
    padding: 0px ${toString (spacingCompact + 1)}px 0px 0px;
    background-color: transparent;
    text-color: inherit;
  }

  element-text {
    font: "${fontFamily} ${fontSize}";
    background-color: transparent;
    text-color: inherit;
    vertical-align: 0.5;
    horizontal-align: 0.0;
  }

  element-text selected {
    background-color: transparent;
    text-color: ${c.fg};
  }

  mode-switcher {
    spacing: ${toString spacingNormal};
    margin: 0;
    padding: 0;
    background-color: transparent;
  }

  button {
    width: 4%;
    padding: 0;
    border-radius: ${radiusButton};
    border: ${toString borderWidth};
    border-color: @border-color;
    background-color: ${c.bgAlt};
    text-color: ${c.fg};
  }

  button selected {
    background-color: @active;
    text-color: ${c.bg};
  }
''
