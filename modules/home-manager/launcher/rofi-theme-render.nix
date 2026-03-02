{config, ...}: theme: let
  c = theme.palette;
  spacing = theme.ui.spacing;
  radius = theme.ui.radius;
in ''
  * {
    font: "${theme.fonts.ui} ${toString theme.fonts.size}";
    icon-theme: "${theme.gtk.iconTheme}";
    background: transparent;
    foreground: ${c."text-primary"};
    text-color: ${c."text-primary"};
    border-color: ${c.border};
    selected: ${c.accent};
    urgent: ${c.error};
    active: ${c.info};
  }

  window {
    location: center;
    anchor: center;
    fullscreen: false;
    width: 34%;
    height: 34%;
    border: 1px;
    border-radius: ${toString radius.md}px;
    border-color: ${c.border};
    background-color: rgba(76, 86, 106, 0.85);
  }

  mainbox {
    spacing: ${toString spacing.sm}px;
    margin: 0;
    padding: ${toString spacing.sm}px;
    background-color: transparent;
    children: [ inputbar, listbox ];
  }

  inputbar {
    spacing: ${toString spacing.xs}px;
    margin: 0;
    padding: ${toString spacing.xs}px;
    border: 1px;
    border-radius: ${toString radius.sm}px;
    border-color: ${c.border};
    background-color: ${c."surface-alt"};
    children: [ prompt, entry ];
  }

  prompt {
    padding: 0 ${toString spacing.xs}px 0 0;
    background-color: transparent;
    text-color: ${c."text-secondary"};
  }

  entry {
    padding: 0;
    border: 0;
    background-color: transparent;
    text-color: ${c."text-primary"};
    placeholder: "Search";
    placeholder-color: ${c."text-muted"};
  }

  listbox {
    spacing: 0;
    margin: 0;
    padding: 0;
    background-color: transparent;
    children: [ listview ];
  }

  listview {
    columns: 2;
    lines: 6;
    cycle: false;
    dynamic: false;
    scrollbar: false;
    layout: vertical;
    reverse: false;
    fixed-columns: true;
    spacing: ${toString spacing.xs}px;
    margin: 0;
    padding: 0;
    background-color: transparent;
  }

  element {
    spacing: ${toString spacing.xs}px;
    margin: 0;
    padding: ${toString spacing.xs}px;
    border: 1px;
    border-radius: ${toString radius.sm}px;
    border-color: transparent;
    background-color: transparent;
    text-color: ${c."text-primary"};
  }

  element normal.normal {
    text-color: ${c."text-primary"};
    background-color: transparent;
  }

  element selected.normal {
    background-color: ${c."accent-subtle"};
    border-color: ${c."accent-muted"};
    text-color: ${c."text-primary"};
  }

  element selected.urgent {
    background-color: ${c.error};
    border-color: ${c.error};
    text-color: ${c."text-on-accent"};
  }

  element normal.urgent {
    text-color: ${c.error};
  }

  element-icon {
    size: 20;
    background-color: transparent;
    text-color: inherit;
  }

  element-text {
    background-color: transparent;
    text-color: inherit;
    vertical-align: 0.5;
  }

  message {
    border: 1px;
    border-radius: ${toString radius.sm}px;
    border-color: ${c.border};
    background-color: ${c."surface-alt"};
    text-color: ${c."text-secondary"};
    padding: ${toString spacing.xs}px;
  }

  button {
    border: 1px;
    border-radius: ${toString radius.sm}px;
    border-color: ${c.border};
    background-color: ${c."surface-alt"};
    text-color: ${c."text-secondary"};
  }

  button selected {
    border-color: ${c.accent};
    background-color: ${c.accent};
    text-color: ${c."text-on-accent"};
  }
''
