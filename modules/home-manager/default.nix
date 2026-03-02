{...}: {
  # Home Manager user-session layer rebuilt for minimal, coherent UX.
  imports = [
    ./theme/default.nix
    ./notifications/swaync.nix
    ./launcher/rofi.nix
    ./shell/zsh.nix
    ./terminal/default.nix
    ./editors/default.nix
    ./browsers/default.nix
    ./waybar/default.nix
    ./desktop-user/hyprland.nix
  ];
}
