{pkgs}: let
  lib = pkgs.lib;
  pick = name:
    if builtins.hasAttr name pkgs
    then builtins.getAttr name pkgs
    else null;
in
  pkgs.mkShell {
    name = "reverse";

    packages = lib.filter (pkg: pkg != null) [
      (pick "binwalk")
      (pick "checksec")
      (pick "clang")
      (pick "gdb")
      (pick "ghidra")
      (pick "gcc")
      (pick "patchelf")
      (pick "python3")
      (
        if pkgs ? python3Packages && pkgs.python3Packages ? pwntools
        then pkgs.python3Packages.pwntools
        else null
      )
      (pick "radare2")
      (pick "strace")
      (pick "upx")
    ];

    shellHook = ''
      export PWNLIB_NOTERM=1
      echo "reverse shell ready"
    '';
  }
