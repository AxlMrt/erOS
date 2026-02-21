{...}: {
  # Home Manager user-session layer rebuilt for minimal, coherent UX.
  imports = [
    ./theme/default.nix
    ./clipboard/cliphist.nix
    ./notifications/swaync.nix
    ./launcher/rofi.nix
    ./shell/zsh.nix
    ./terminal/kitty.nix
    ./editors/vscode.nix
    ./waybar/default.nix
    ./desktop-user/hyprland.nix
  ];
}
