{pkgs}: let
  lib = pkgs.lib;
  helpers = import ../lib/shell-helpers.nix {inherit pkgs;};

  optionalTools = [
    "ad-miner"
    "aiodnsbrute"
    "amass"
    "asn"
    "assetfinder"
    "bind"
    "bloodhound"
    "bloodhound-py"
    "cantoolz"
    "certgraph"
    "chaos"
    "checkpwn"
    "clairvoyance"
    "cloudlist"
    "dnsenum"
    "dnsrecon"
    "dnstracer"
    "dnstwist"
    "dnsx"
    "dorkscout"
    "dump1090-fa"
    "enum4linux"
    "enum4linux-ng"
    "fierce"
    "fping"
    "gau"
    "geoip"
    "ghdorker"
    "git-hound"
    "gitleaks"
    "gomapenum"
    "gowitness"
    "graphinder"
    "holehe"
    "httping"
    "katana"
    "kiterunner"
    "knockpy"
    "ldeep"
    "linux-exploit-suggester"
    "maltego"
    "metabigor"
    "metasploit"
    "netdiscover"
    "netmask"
    "ntlmrecon"
    "octosuite"
    "parsero"
    "photon"
    "proxmark3"
    "rita"
    "sherlock"
    "sleuthkit"
    "smbmap"
    "sn0int"
    "sniffglue"
    "snmpcheck"
    "snscrape"
    "social-engineer-toolkit"
    "socialscan"
    "subfinder"
    "subjs"
    "thc-ipv6"
    "theharvester"
    "traceroute"
    "trufflehog"
    "uncover"
    "webanalyze"
    "websploit"
    "whatweb"
    "zgrab2"
    "python313Packages.shodan"
    "python313Packages.spyse-python"
  ];
  missingOptional = helpers.missingOptionalPaths optionalTools;
in
  pkgs.mkShell {
    name = "osint";

    packages = helpers.filterPresent (
      [
        (helpers.require "curl")
        (helpers.require "git")
        (helpers.require "jq")
        (helpers.pickFirstRequired "osint" ["amass" "theHarvester"])
        (helpers.pickFirstRequired "osint" ["whois" "bind"])
      ]
      ++ helpers.pickOptionalPaths optionalTools
    );

    shellHook = ''
      if [[ "${toString missingOptional}" != "" ]]; then
        echo "osint optional tools not available in current nixpkgs: ${lib.concatStringsSep ", " missingOptional}"
      fi
      echo "osint shell ready"
    '';
  }
