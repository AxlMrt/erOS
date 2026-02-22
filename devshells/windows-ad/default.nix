{pkgs}: let
  lib = pkgs.lib;
  pick = name:
    if builtins.hasAttr name pkgs
    then builtins.getAttr name pkgs
    else null;
in
  pkgs.mkShell {
    name = "windows-ad";

    packages = lib.filter (pkg: pkg != null) [
      (pick "impacket")
      (pick "krb5")
      (pick "ldapvi")
      (pick "netcat")
      (pick "nmap")
      (pick "openldap")
      (pick "openvpn")
      (pick "python3")
      (pick "responder")
      (pick "samba")
      (pick "smbclient")
      (pick "wireguard-tools")
    ];

    shellHook = ''
      export KRB5_CONFIG="${pkgs.krb5}/etc/krb5.conf"
      echo "windows-ad shell ready"
    '';
  }
