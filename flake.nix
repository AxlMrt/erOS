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

  outputs = {
    nixpkgs,
    home-manager,
    hyprland,
    ...
  }: let
    hosts = {
      default = {
        path = ./hosts/default;
        system = "x86_64-linux";
        hostname = "axlmrt-laptop";
        username = "axlmrt";
      };
    };

    defaultHost = "default";

    profileModules = {
      base = [
        ./modules/core
      ];

      desktop = [
        ./modules/desktop-system
      ];

      # Offensive security toolset (pentest profile).
      pentest = [
        ./modules/pentest
      ];
    };

    mkHost = {
      hostName,
      profiles,
    }: let
      host = hosts.${hostName};
      homeManagerModule = [
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            hostname = host.hostname;
            username = host.username;
          };
          home-manager.users.${host.username} = import (./users + "/${host.username}");
        }
      ];
    in
      nixpkgs.lib.nixosSystem {
        system = host.system;
        specialArgs = {
          hostname = host.hostname;
          username = host.username;
        };

        modules =
          [
            host.path
          ]
          ++ (builtins.concatLists (map (name: profileModules.${name}) profiles))
          ++ (
            if builtins.elem "desktop" profiles
            then homeManagerModule
            else []
          );
      };

    mkHostProfiles = hostName: {
      "${hostName}-base" = mkHost {
        inherit hostName;
        profiles = ["base"];
      };

      "${hostName}-desktop" = mkHost {
        inherit hostName;
        profiles = ["base" "desktop"];
      };

      "${hostName}-pentest" = mkHost {
        inherit hostName;
        profiles = ["base" "desktop" "pentest"];
      };
    };

    hostConfigurations =
      builtins.foldl'
      (acc: hostName: acc // (mkHostProfiles hostName))
      {}
      (builtins.attrNames hosts);
  in {
    nixosConfigurations =
      hostConfigurations
      // {
        # Minimal host baseline (no GUI/home-manager).
        base = mkHost {
          hostName = defaultHost;
          profiles = ["base"];
        };

        # Daily workstation profile.
        desktop = mkHost {
          hostName = defaultHost;
          profiles = ["base" "desktop"];
        };

        # Full offensive-security workstation.
        pentest = mkHost {
          hostName = defaultHost;
          profiles = ["base" "desktop" "pentest"];
        };

        # Keep the historical target name for compatibility.
        default = mkHost {
          hostName = defaultHost;
          profiles = ["base" "desktop" "pentest"];
        };
      };

    formatter.${hosts.${defaultHost}.system} = nixpkgs.legacyPackages.${hosts.${defaultHost}.system}.alejandra;
  };
}
