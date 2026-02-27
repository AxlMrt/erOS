{pkgs}: let
  lib = pkgs.lib;
  helpers = import ../lib/shell-helpers.nix {inherit pkgs;};

  optionalTools = [
    "frida-tools"
    "objection"
    "mitmproxy"
  ];
  missingOptional = helpers.missingOptionalPaths optionalTools;
in
  pkgs.mkShell {
    name = "mobile-ios";

    packages = helpers.filterPresent [
      (helpers.require "git")
      (helpers.require "python3")
      (helpers.pickFirstRequired "mobile-ios" ["libimobiledevice" "ifuse"])
      (helpers.pickOptional "usbmuxd")
      (helpers.pickOptional "ideviceinstaller")
      (helpers.pickOptional "frida-tools")
      (helpers.pickOptional "objection")
      (helpers.pickOptional "mitmproxy")
    ];

    shellHook = ''
      export MOBILE_IOS_WORKDIR="$PWD/.mobile-ios"
      mkdir -p "$MOBILE_IOS_WORKDIR"
      if [[ "${toString missingOptional}" != "" ]]; then
        echo "mobile-ios optional tools not available in current nixpkgs: ${lib.concatStringsSep ", " missingOptional}"
      fi
      echo "mobile-ios shell ready"
    '';
  }
