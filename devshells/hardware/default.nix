{pkgs}: let
  lib = pkgs.lib;
  helpers = import ../lib/shell-helpers.nix {inherit pkgs;};

  optionalTools = [
    "firmware-mod-kit"
    "openocd"
    "minicom"
    "sigrok-cli"
    "rfcat"
    "cantoolz"
    "chipsec"
    "hackrf"
    "kalibrate-rtl"
    "kismet"
    "libosmocore"
    "mfcuk"
    "mfoc"
    "multimon-ng"
    "proxmark3"
    "saleae-logic"
    "saleae-logic-2"
    "thc-ipv6"
    "wavemon"
    "wifite2"
    "aircrack-ng"
    "bully"
    "cowpatty"
    "hcxdumptool"
    "hcxtools"
    "hostapd-mana"
    "pixiewps"
    "reaverwps-t6x"
  ];
  missingOptional = helpers.missingOptionalPaths optionalTools;
in
  pkgs.mkShell {
    name = "hardware";

    packages = helpers.filterPresent (
      [
        (helpers.require "binwalk")
        (helpers.require "file")
        (helpers.require "git")
        (helpers.require "python3")
        (helpers.require "radare2")
        (helpers.require "strace")
      ]
      ++ helpers.pickOptionalPaths optionalTools
    );

    shellHook = ''
      export HARDWARE_WORKDIR="$PWD/.hardware"
      mkdir -p "$HARDWARE_WORKDIR"
      if [[ "${toString missingOptional}" != "" ]]; then
        echo "hardware shell optional tools not available in current nixpkgs: ${lib.concatStringsSep ", " missingOptional}"
      fi
      echo "hardware shell ready"
    '';
  }
