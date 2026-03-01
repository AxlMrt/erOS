{pkgs}: let
  lib = pkgs.lib;
  helpers = import ../lib/shell-helpers.nix {inherit pkgs;};
  impacketPkg = helpers.pickFirstOptional ["impacket"];
  impacketPy3Pkg = helpers.pickOptionalPath "python3Packages.impacket";
  impacketPy313Pkg = helpers.pickOptionalPath "python313Packages.impacket";
  responderPkg = helpers.pickOptional "responder";
  ldapviPkg = helpers.pickOptional "ldapvi";
  openldapPkg = helpers.pickOptional "openldap";
  smbclientPkg = helpers.pickOptional "smbclient";
  hashcatPkg = helpers.pickOptional "hashcat";
  johnPkg = helpers.pickOptional "john";

  optionalTools = [
    "bloodhound-py"
    "bloodhound"
    "adenum"
    "ad-miner"
    "certsync"
    "certipy"
    "netexec"
    "evil-winrm"
    "ldapdomaindump"
    "coercer"
    "enum4linux"
    "enum4linux-ng"
    "freerdp"
    "fscan"
    "kerbrute"
    "ldeep"
    "ntlmrecon"
    "powersploit"
    "responder"
    "smbmap"
    "python313Packages.certipy-ad"
    "python313Packages.dnspython"
    "python313Packages.impacket"
    "python313Packages.ldapdomaindump"
    "python313Packages.minidump"
    "python313Packages.minikerberos"
    "python313Packages.myjwt"
    "python313Packages.pypykatz"
    "python313Packages.ropper"
    "python313Packages.scapy"
  ];
  optionalCoreNames =
    lib.optional (impacketPkg == null && impacketPy3Pkg == null && impacketPy313Pkg == null) "impacket"
    ++ lib.optional (responderPkg == null) "responder"
    ++ lib.optional (ldapviPkg == null) "ldapvi"
    ++ lib.optional (openldapPkg == null) "openldap"
    ++ lib.optional (smbclientPkg == null) "smbclient"
    ++ lib.optional (hashcatPkg == null) "hashcat"
    ++ lib.optional (johnPkg == null) "john";
  missingOptional = helpers.missingOptionalPaths optionalTools;
in
  pkgs.mkShell {
    name = "windows-ad";

    packages = helpers.filterPresent (
      [
        (helpers.require "krb5")
        (helpers.require "netcat")
        (helpers.require "nmap")
        (helpers.require "openvpn")
        (helpers.require "python3")
        (helpers.require "samba")
        impacketPkg
        impacketPy3Pkg
        impacketPy313Pkg
        responderPkg
        ldapviPkg
        openldapPkg
        smbclientPkg
        hashcatPkg
        johnPkg
      ]
      ++ helpers.pickOptionalPaths optionalTools
    );

    shellHook = ''
      export KRB5_CONFIG="${pkgs.krb5}/etc/krb5.conf"
      export BLOODHOUND_DIR="$PWD/.bloodhound"
      mkdir -p "$BLOODHOUND_DIR"
      if [[ "${toString optionalCoreNames}" != "" ]]; then
        echo "windows-ad optional core tools not available in current nixpkgs: ${lib.concatStringsSep ", " optionalCoreNames}"
      fi
      if [[ "${toString missingOptional}" != "" ]]; then
        echo "windows-ad optional tools not available in current nixpkgs: ${lib.concatStringsSep ", " missingOptional}"
      fi
      echo "windows-ad shell ready"
    '';
  }
