{
  description = "ErOS Minimal Setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
	./hosts/default/configuration.nix

	# Core configuration
	./modules/core/system.nix
	./modules/core/networking.nix

	# Desktop
	./modules/desktop/apps.nix
	./modules/desktop/hyprland.nix
	
	# Pentesting
	./modules/security/base-tools.nix
	./modules/security/recon.nix
	./modules/security/web.nix

	home-manager.nixosModules.home-manager
	{
	  home-manager.useGlobalPkgs = true;
	  home-manager.useUserPackages = true;
	  home-manager.users.axlmrt = import ./home/home.nix;
	}
      ];
    };
  };
}
