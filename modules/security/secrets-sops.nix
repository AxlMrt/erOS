{
  lib,
  inputs,
  config,
  ...
}: let
  cfg = config.eros.security.secrets;
  selectedSopsFile = cfg.files.${cfg.profile} or null;
in {
  imports = [inputs.sops-nix.nixosModules.sops];

  options.eros.security.secrets = {
    enable = lib.mkEnableOption "sops-managed secrets";

    ageKeyFile = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/sops-nix/key.txt";
      description = "Age private key path used by sops-nix.";
    };

    profile = lib.mkOption {
      type = lib.types.str;
      default = "workstation";
      description = "Active secret profile key used to select a file from eros.security.secrets.files.";
    };

    files = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = {};
      description = "Mapping of secret profile names to SOPS files.";
    };

    declarations = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            key = lib.mkOption {
              type = lib.types.str;
              description = "Key inside the encrypted SOPS document.";
            };
            owner = lib.mkOption {
              type = lib.types.str;
              default = "root";
            };
            group = lib.mkOption {
              type = lib.types.str;
              default = "root";
            };
            mode = lib.mkOption {
              type = lib.types.str;
              default = "0400";
            };
            path = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };
            sopsFile = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
            };
          };
        }
      );
      default = {};
      description = "Declarative secret definitions mapped into sops.secrets.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.profile != "";
        message = "eros.security.secrets.profile must be a non-empty string.";
      }
      {
        assertion = builtins.hasAttr cfg.profile cfg.files;
        message = "eros.security.secrets.files must contain the selected profile key.";
      }
      {
        assertion = selectedSopsFile != null;
        message = "eros.security.secrets selected SOPS file resolved to null; check eros.security.secrets.profile and eros.security.secrets.files.";
      }
    ];

    sops =
      {
        age.keyFile = cfg.ageKeyFile;
        validateSopsFiles = true;
        defaultSopsFile = selectedSopsFile;
      }
      // {
        secrets =
          lib.mapAttrs (
            _: decl:
              {
                inherit (decl) key owner group mode;
              }
              // lib.optionalAttrs (decl.path != null) {
                path = decl.path;
              }
              // {
                sopsFile =
                  if decl.sopsFile != null
                  then decl.sopsFile
                  else selectedSopsFile;
              }
          )
          cfg.declarations;
      };
  };
}
