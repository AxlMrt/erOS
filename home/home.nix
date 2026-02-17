{ config, pkgs, ... }:

{
  home.username = "axlmrt";
  home.homeDirectory = "/home/axlmrt";

  home.stateVersion = "25.11";

  programs.git.enable = true;
  programs.kitty.enable = true;
  programs.waybar.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";

      exec-once = [
	"waybar"
      ];

      monitor = ",preferred,auto,1";

      input = {
	kb_layout = "fr";
      };

      bind = [
	# Browser
	"$mod, F, exec, firefox"
	
	# Terminal
	"$mod, T, exec, kitty"

	"$mod, D, exec, wofi --show drun"
	"$mod, Q, killactive"
	"$mod, E, exit"
      ];
    };
  };

  imports = [
    ./zsh/zsh.nix
    ./terminal/kitty.nix
  ];
}
