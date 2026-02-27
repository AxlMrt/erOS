{pkgs}: let
  lib = pkgs.lib;
  helpers = import ../lib/shell-helpers.nix {inherit pkgs;};

  optionalTools = [
    "amoco"
    "androguard"
    "apkid"
    "apkleaks"
    "apktool"
    "bamf"
    "binwalk"
    "bsdiff"
    "bvi"
    "bytecode-viewer"
    "capstone"
    "cfr"
    "chipsec"
    "ctypes_sh"
    "cutter"
    "cutterPlugins.rz-ghidra"
    "dex2jar"
    "edb"
    "elfkickers"
    "elfutils"
    "eresi"
    "flare-floss"
    "flasm"
    "frida-tools"
    "gdb"
    "gdbgui"
    "ghidra"
    "iaito"
    "jadx"
    "jsbeautifier"
    "lief"
    "lldb"
    "loadlibrary"
    "ltrace"
    "ms-sys"
    "nasm"
    "oletools"
    "osslsigncode"
    "packer"
    "pe-bear"
    "pev"
    "pixd"
    "procdump"
    "procyon"
    "pwntools"
    "quark-engine"
    "radare2"
    "rizin"
    "rizinPlugins.rz-ghidra"
    "rr"
    "saleae-logic"
    "saleae-logic-2"
    "shellnoob"
    "strace"
    "udis86"
    "upx"
    "valgrind"
    "vt-cli"
    "wcc"
    "wxhexeditor"
    "yara"
    "python313Packages.distorm3"
    "python313Packages.frida-python"
    "python313Packages.pcodedmp"
    "python313Packages.pwntools"
    "python313Packages.pyaxmlparser"
    "python313Packages.pyjsparser"
    "python313Packages.ropper"
    "python313Packages.vt-py"
    "python313Packages.yara-python"
  ];
  missingOptional = helpers.missingOptionalPaths optionalTools;
in
  pkgs.mkShell {
    name = "reverse";

    packages = helpers.filterPresent (
      [
        (helpers.pickOptional "checksec")
        (helpers.pickOptional "clang")
        (helpers.pickOptional "gcc")
        (helpers.pickOptional "patchelf")
        (helpers.require "python3")
      ]
      ++ helpers.pickOptionalPaths optionalTools
    );

    shellHook = ''
      export PWNLIB_NOTERM=1
      if [[ "${toString missingOptional}" != "" ]]; then
        echo "reverse optional tools not available in current nixpkgs: ${lib.concatStringsSep ", " missingOptional}"
      fi
      echo "reverse shell ready"
    '';
  }
