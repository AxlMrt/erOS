{...}: {
  # Shared Home Manager building blocks (user-session layer).
  imports = [
    ./emoji.nix
    ./shell/zsh.nix
    ./terminal/kitty.nix
    ./editors/vscode.nix
    ./waybar/waybar-catpuccin.nix
    ./desktop-user/hyprland.nix
  ];
}
