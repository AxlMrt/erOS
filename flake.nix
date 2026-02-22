{
  description = "ErOS Security Architecture";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    sops-nix,
    ...
  }: let
    lib = nixpkgs.lib;

    hosts = {
      default = {
        path = ./hosts/default;
        system = "x86_64-linux";
        hostname = "axlmrt-laptop";
        username = "axlmrt";
      };
    };

    defaultHost = "default";

    systems = lib.unique (map (name: hosts.${name}.system) (builtins.attrNames hosts));
    forAllSystems = lib.genAttrs systems;
    pkgsFor = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

    secretsGuardFor = system: let
      pkgs = pkgsFor system;
    in
      pkgs.writeShellApplication {
        name = "eros-secrets-guard";
        runtimeInputs = with pkgs; [coreutils gnugrep];
        text = ''
          set -euo pipefail

          check_file() {
            local file="$1"
            if [[ ! -f "$file" ]]; then
              echo "[secrets-guard] missing file: $file" >&2
              return 1
            fi

            if grep -q "REPLACE_ME" "$file"; then
              echo "[secrets-guard] placeholder detected in: $file" >&2
              return 1
            fi

            if ! grep -q '^sops:' "$file"; then
              echo "[secrets-guard] file is not SOPS-encrypted (missing sops metadata): $file" >&2
              return 1
            fi

            if ! grep -q 'ENC\\[' "$file"; then
              echo "[secrets-guard] encrypted payload marker not found: $file" >&2
              return 1
            fi
          }

          check_file "${./secrets/offensive.yaml}"
          check_file "${./secrets/lab.yaml}"

          echo "[secrets-guard] OK: encrypted secrets are ready"
        '';
      };

    modernProfileModules = {
      sec-desktop = [
        ./modules/core
        ./modules/security
        ./modules/security/secrets-sops.nix
        ./modules/network
        ./modules/opsec
        ./modules/offensive/native
        ./modules/desktop-system
        ({config, ...}: {
          eros = {
            security.hardening.enable = true;
            security.secrets.enable = true;
            security.secrets.profile = "offensive";
            security.secrets.files = {
              offensive = ./secrets/offensive.yaml;
              lab = ./secrets/lab.yaml;
            };
            security.secrets.declarations = {
              wgConfig = {
                key = "vpn.wireguard.config";
                owner = "root";
                group = "root";
                mode = "0400";
              };
              openvpnClientConfig = {
                key = "vpn.openvpn.client_config";
                owner = "root";
                group = "root";
                mode = "0400";
              };
            };
            network.profile = "untrusted";
            network.tempPorts.enable = true;
            opsec.enable = true;
            opsec.identityProfile = "offensive";
            opsec.dnsProfile = "quad9";
            opsec.macSpoof.enable = true;
            opsec.vpn.provider = "openvpn";
            opsec.vpn.autoConnect.enable = true;
            opsec.vpn.openvpnConfigFile = config.sops.secrets.openvpnClientConfig.path;
            opsec.vpn.wireguardConfigFile = config.sops.secrets.wgConfig.path;
            offensive.native.enable = true;
          };
        })
      ];

      sec-headless = [
        ./modules/core
        ./modules/security
        ./modules/security/secrets-sops.nix
        ./modules/network
        ./modules/opsec
        ./modules/offensive/native
        ({config, ...}: {
          eros = {
            security.hardening.enable = true;
            security.secrets.enable = true;
            security.secrets.profile = "offensive";
            security.secrets.files = {
              offensive = ./secrets/offensive.yaml;
              lab = ./secrets/lab.yaml;
            };
            security.secrets.declarations = {
              wgConfig = {
                key = "vpn.wireguard.config";
                owner = "root";
                group = "root";
                mode = "0400";
              };
              openvpnClientConfig = {
                key = "vpn.openvpn.client_config";
                owner = "root";
                group = "root";
                mode = "0400";
              };
            };
            network.profile = "untrusted";
            network.tempPorts.enable = true;
            opsec.enable = true;
            opsec.identityProfile = "offensive";
            opsec.dnsProfile = "quad9";
            opsec.macSpoof.enable = true;
            opsec.vpn.provider = "openvpn";
            opsec.vpn.autoConnect.enable = true;
            opsec.vpn.openvpnConfigFile = config.sops.secrets.openvpnClientConfig.path;
            opsec.vpn.wireguardConfigFile = config.sops.secrets.wgConfig.path;
            offensive.native.enable = true;
          };
        })
      ];

      lab-host = [
        ./modules/core
        ./modules/security
        ./modules/security/secrets-sops.nix
        ./modules/network
        ./modules/opsec
        ./modules/offensive/native
        ./modules/virtualization/lab.nix
        ({config, ...}: {
          eros = {
            security.hardening.enable = true;
            security.secrets.enable = true;
            security.secrets.profile = "lab";
            security.secrets.files = {
              offensive = ./secrets/offensive.yaml;
              lab = ./secrets/lab.yaml;
            };
            security.secrets.declarations = {
              wgConfig = {
                key = "vpn.wireguard.config";
                owner = "root";
                group = "root";
                mode = "0400";
              };
            };
            network.profile = "lab";
            network.tempPorts.enable = true;
            opsec.enable = true;
            opsec.identityProfile = "lab";
            opsec.dnsProfile = "system";
            opsec.macSpoof.enable = false;
            opsec.vpn.provider = "wireguard";
            opsec.vpn.autoConnect.enable = true;
            opsec.vpn.wireguardConfigFile = config.sops.secrets.wgConfig.path;
            offensive.native.enable = false;
            lab.virtualization.enable = true;
          };
        })
      ];
    };

    mkModernHost = {
      hostName,
      profile,
    }: let
      host = hosts.${hostName};
      includeHomeManager = profile == "sec-desktop";
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
      lib.nixosSystem {
        system = host.system;
        specialArgs = {
          hostname = host.hostname;
          username = host.username;
          inputs = {
            inherit sops-nix;
          };
        };
        modules =
          [
            host.path
          ]
          ++ modernProfileModules.${profile}
          ++ (
            if includeHomeManager
            then homeManagerModule
            else []
          );
      };

    modernHostConfigurations =
      builtins.foldl'
      (
        acc: hostName:
          acc
          // {
            "${hostName}-sec-desktop" = mkModernHost {
              inherit hostName;
              profile = "sec-desktop";
            };
            "${hostName}-sec-headless" = mkModernHost {
              inherit hostName;
              profile = "sec-headless";
            };
            "${hostName}-lab-host" = mkModernHost {
              inherit hostName;
              profile = "lab-host";
            };
          }
      )
      {}
      (builtins.attrNames hosts);
  in {
    nixosConfigurations = modernHostConfigurations;

    devShells = forAllSystems (
      system: let
        pkgs = pkgsFor system;
      in {
        web-pentest = import ./devshells/web-pentest {
          inherit pkgs;
        };
        network-pentest = import ./devshells/network-pentest {
          inherit pkgs;
        };
        windows-ad = import ./devshells/windows-ad {
          inherit pkgs;
        };
        malware-analysis = import ./devshells/malware-analysis {
          inherit pkgs;
        };
        osint = import ./devshells/osint {
          inherit pkgs;
        };
        reverse = import ./devshells/reverse {
          inherit pkgs;
        };
        exploit-dev = import ./devshells/exploit-dev {
          inherit pkgs;
        };
      }
    );

    packages = forAllSystems (system: {
      secrets-guard = secretsGuardFor system;
    });

    apps = forAllSystems (system: {
      secrets-guard = {
        type = "app";
        program = "${self.packages.${system}.secrets-guard}/bin/eros-secrets-guard";
        meta.description = "Validate that tracked secrets are encrypted and placeholder-free";
      };
      default = self.apps.${system}.secrets-guard;
    });

    formatter.${hosts.${defaultHost}.system} = nixpkgs.legacyPackages.${hosts.${defaultHost}.system}.alejandra;
  };
}
