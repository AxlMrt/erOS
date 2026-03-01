{
  description = "ErOS Security Architecture";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
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
    nixvim,
    nvf,
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
    desktopProfiles = ["sec-desktop" "lab-desktop"];

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

            if ! grep -q 'ENC\[' "$file"; then
              echo "[secrets-guard] encrypted payload marker not found: $file" >&2
              return 1
            fi
          }

          check_file "${./secrets/secrets.yaml}"

          echo "[secrets-guard] OK: encrypted secrets are ready"
        '';
      };

    sharedSecretsFile = ./secrets/secrets.yaml;
    sharedSecretsFiles = {
      offensive = sharedSecretsFile;
      lab = sharedSecretsFile;
    };
    openvpnClientDeclaration = {
      openvpnClientConfig = {
        key = "vpn/openvpn/client_config";
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };

    commonProfileModules = [
      ./modules/core
      ./modules/security
      ./modules/security/secrets-sops.nix
      ./modules/network
      ./modules/opsec
      ./modules/core/hyprland.nix
    ];

    mkErosProfileModule = {
      secretsProfile,
      networkProfile,
      identityProfile,
      dnsProfile,
      macSpoof,
      enableLabVirtualization ? false,
    }: {config, ...}: {
      eros =
        {
          security.hardening.enable = true;
          security.secrets.enable = true;
          security.secrets.profile = secretsProfile;
          security.secrets.files = sharedSecretsFiles;
          security.secrets.declarations = openvpnClientDeclaration;
          network.profile = networkProfile;
          network.tempPorts.enable = true;
          opsec.enable = true;
          opsec.identityProfile = identityProfile;
          opsec.dnsProfile = dnsProfile;
          opsec.macSpoof.enable = macSpoof;
          opsec.vpn.provider = "openvpn";
          opsec.vpn.autoConnect.enable = true;
          opsec.vpn.openvpnConfigFile = config.sops.secrets.openvpnClientConfig.path;
        }
        // lib.optionalAttrs enableLabVirtualization {
          lab.virtualization.enable = true;
        };
    };

    devShellNames = [
      "web-pentest"
      "network-pentest"
      "windows-ad"
      "malware-analysis"
      "osint"
      "reverse"
      "exploit-dev"
      "cloud-pentest"
      "mobile"
      "mobile-ios"
      "hardware"
    ];

    mkDevShellSet = pkgs:
      builtins.listToAttrs (map (name: {
          inherit name;
          value = import (./devshells + "/${name}") {inherit pkgs;};
        })
        devShellNames);

    profileOutputs = [
      {
        suffix = "sec";
        profile = "sec-desktop";
      }
      {
        suffix = "lab";
        profile = "lab-desktop";
      }
    ];

    shellHealthFor = system: let
      pkgs = pkgsFor system;
      flakePath = toString ./.;
    in
      pkgs.writeShellApplication {
        name = "eros-shell-health";
        runtimeInputs = with pkgs; [coreutils nix];
        text = ''
          set -euo pipefail

          mode="''${1:-resolve}"
          shells=(
            web-pentest
            network-pentest
            windows-ad
            malware-analysis
            osint
            reverse
            exploit-dev
            cloud-pentest
            mobile
            mobile-ios
            hardware
          )

          echo "[shell-health] mode=$mode system=${system}"

          for shell in "''${shells[@]}"; do
            case "$mode" in
              resolve)
                nix eval "${flakePath}#devShells.${system}.''${shell}.name" >/dev/null
                ;;
              build)
                nix develop "${flakePath}#''${shell}" -c true >/dev/null
                ;;
              *)
                echo "Usage: eros-shell-health [resolve|build]" >&2
                exit 1
                ;;
            esac
            echo "[shell-health] ok: ''${shell}"
          done

          echo "[shell-health] all checks passed"
        '';
      };

    qaCheckFor = system: let
      pkgs = pkgsFor system;
      flakePath = toString ./.;
    in
      pkgs.writeShellApplication {
        name = "eros-qa-check";
        runtimeInputs = with pkgs; [nix];
        text = ''
          set -euo pipefail

          mode="''${1:-fast}"

          echo "[qa-check] mode=$mode"
          echo "[qa-check] running nix flake check"
          nix flake check "${flakePath}"

          echo "[qa-check] running shell-health resolve"
          nix run "${flakePath}#shell-health" -- resolve

          if [[ "$mode" == "full" ]]; then
            echo "[qa-check] running secrets-guard"
            nix run "${flakePath}#secrets-guard"
          elif [[ "$mode" != "fast" ]]; then
            echo "Usage: eros-qa-check [fast|full]" >&2
            exit 1
          fi

          echo "[qa-check] all checks passed"
        '';
      };

    modernProfileModules = {
      sec-desktop =
        commonProfileModules
        ++ [
          (mkErosProfileModule {
            secretsProfile = "offensive";
            networkProfile = "untrusted";
            identityProfile = "offensive";
            dnsProfile = "quad9";
            macSpoof = true;
          })
        ];

      lab-desktop =
        commonProfileModules
        ++ [
          ./modules/virtualization/lab.nix
          (mkErosProfileModule {
            secretsProfile = "lab";
            networkProfile = "lab";
            identityProfile = "lab";
            dnsProfile = "system";
            macSpoof = false;
            enableLabVirtualization = true;
          })
        ];
    };

    mkModernHost = {
      hostName,
      profile,
    }: let
      host = hosts.${hostName};
      includeHomeManager = builtins.elem profile desktopProfiles;
      homeManagerModule = [
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            hostname = host.hostname;
            username = host.username;
            inputs = {
              inherit nixvim nvf;
            };
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
          // builtins.listToAttrs
          (map (entry: {
              name = "${hostName}-${entry.suffix}";
              value = mkModernHost {
                inherit hostName;
                profile = entry.profile;
              };
            })
            profileOutputs)
      )
      {}
      (builtins.attrNames hosts);
  in {
    nixosConfigurations = modernHostConfigurations;

    devShells = forAllSystems (system: mkDevShellSet (pkgsFor system));

    packages = forAllSystems (system: {
      secrets-guard = secretsGuardFor system;
      shell-health = shellHealthFor system;
      qa-check = qaCheckFor system;
    });

    apps = forAllSystems (system: let
      mkToolApp = {
        packageName,
        binary,
        description,
      }: {
        type = "app";
        program = "${self.packages.${system}.${packageName}}/bin/${binary}";
        meta.description = description;
      };
    in {
      secrets-guard = mkToolApp {
        packageName = "secrets-guard";
        binary = "eros-secrets-guard";
        description = "Validate that tracked secrets are encrypted and placeholder-free";
      };
      shell-health = mkToolApp {
        packageName = "shell-health";
        binary = "eros-shell-health";
        description = "Validate devShell resolution/build health";
      };
      qa-check = mkToolApp {
        packageName = "qa-check";
        binary = "eros-qa-check";
        description = "Run standardized ErOS QA checks";
      };
      default = self.apps.${system}.secrets-guard;
    });

    formatter.${hosts.${defaultHost}.system} = (pkgsFor hosts.${defaultHost}.system).alejandra;
  };
}
