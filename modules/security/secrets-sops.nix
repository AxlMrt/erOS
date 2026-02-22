{
  lib,
  inputs,
  config,
  ...
}: let
  cfg = config.eros.security.secrets;
  selectedSopsFile =
    if cfg.profile != null
    then cfg.files.${cfg.profile} or null
    else cfg.defaultSopsFile;
in {
  imports = [inputs.sops-nix.nixosModules.sops];

  options.eros.security.secrets = {
    enable = lib.mkEnableOption "sops-managed secrets";

    ageKeyFile = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/sops-nix/key.txt";
      description = "Age private key path used by sops-nix.";
    };

    defaultSopsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Fallback SOPS file when no profile-specific file is selected.";
    };

    profile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
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
    sops =
      {
        age.keyFile = cfg.ageKeyFile;
        validateSopsFiles = false;
      }
      // lib.optionalAttrs (selectedSopsFile != null) {
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
              // lib.optionalAttrs (decl.sopsFile != null || selectedSopsFile != null) {
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
