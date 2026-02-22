{pkgs}: let
  pick = names: let
    found = builtins.filter (name: builtins.hasAttr name pkgs) names;
  in
    if found == []
    then pkgs.git
    else builtins.getAttr (builtins.head found) pkgs;
in
  pkgs.mkShell {
    name = "osint";

    packages = [
      pkgs.curl
      pkgs.git
      pkgs.jq
      (pick ["amass" "theHarvester"])
      (pick ["whois" "bind"])
    ];

    shellHook = ''
      echo "osint shell ready"
    '';
  }
