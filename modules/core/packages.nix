{
  lib,
  config,
  pkgs,
  ...
}: let
  hyprlandEnabled = lib.attrByPath ["programs" "hyprland" "enable"] false config;

  coreSystemPackages = with pkgs; [
    curl # Network data transfers and API checks
    git # Source control and workflow baseline
    jq # JSON filtering for tooling pipelines
    killall # Fast process cleanup during testing
    obsidian # Note-taking and knowledge management
    ripgrep # Fast recursive search for code and artifacts
    tmux # Long-running session management
    vim # Emergency editor available everywhere
    wget # Scriptable file retrieval
  ];

  coreArchivePackages = with pkgs; [
    unzip # Handle ZIP archives
    zip # Create ZIP archives
  ];

  coreInfraPackages = with pkgs; [
    docker-compose # Declarative multi-container training stacks
  ];

  corePentestNetworkPackages = with pkgs; [
    bind # DNS tooling baseline
    dnsutils # DNS inspection and troubleshooting
    nmap # Core network scanning baseline
    openssl # TLS/crypto inspection baseline
    tcpdump # Packet capture baseline
    traceroute # Route/path diagnostics baseline
    whois # Domain and network ownership lookup
  ];

  coreDesktopPackages = lib.optionals hyprlandEnabled (with pkgs; [
    brightnessctl # Backlight control for laptop usage
    cliphist # Clipboard history utility used by Hyprland bindings
    firefox # Main desktop browser
    grim # Wayland screenshot utility
    kitty # Desktop terminal emulator
    rofi # Launcher and dmenu replacement
    slurp # Region selector for Wayland tools
    swww # Wallpaper daemon for Hyprland
    waybar # Status bar for Hyprland
    wl-clipboard # Wayland clipboard CLI for cliphist integrations
  ]);
in {
  environment.systemPackages = lib.unique (
    coreSystemPackages
    ++ coreArchivePackages
    ++ coreInfraPackages
    ++ corePentestNetworkPackages
    ++ coreDesktopPackages
  );
}
