{pkgs}: let
  lib = pkgs.lib;
  helpers = import ../lib/shell-helpers.nix {inherit pkgs;};

  optionalTools = [
    "frida-tools"
    "frida"
    "objection"
    "dex2jar"
    "apkid"
    "apkleaks"
    "binwalk"
    "bsdiff"
    "capstone"
    "cargo-ndk"
    "ctypes_sh"
    "cutter"
    "cutterPlugins.rz-ghidra"
    "edb"
    "eresi"
    "flasm"
    "ghidra"
    "ghost"
    "iaito"
    "jadx"
    "jsbeautifier"
    "kalibrate-rtl"
    "lief"
    "pe-bear"
    "pev"
    "pwntools"
    "quark-engine"
    "radare2"
    "rizin"
    "rizinPlugins.rz-ghidra"
    "udis86"
    "python313Packages.distorm3"
    "python313Packages.frida-python"
    "python313Packages.pwntools"
    "python313Packages.pyaxmlparser"
    "python313Packages.pyjsparser"
  ];
  missingOptional = helpers.missingOptionalPaths optionalTools;
in
  pkgs.mkShell {
    name = "mobile";

    packages = helpers.filterPresent (
      [
        (helpers.require "android-tools")
        (helpers.require "apktool")
        (helpers.require "git")
        (helpers.require "python3")
        (helpers.pickFirstRequired "mobile" ["jadx" "jadx-bin"])
      ]
      ++ helpers.pickOptionalPaths optionalTools
    );

    shellHook = ''
      export MOBILE_WORKDIR="$PWD/.mobile"
      mkdir -p "$MOBILE_WORKDIR"
      if [[ "${toString missingOptional}" != "" ]]; then
        echo "mobile shell optional tools not available in current nixpkgs: ${lib.concatStringsSep ", " missingOptional}"
      fi
      echo "mobile shell ready"
    '';
  }
