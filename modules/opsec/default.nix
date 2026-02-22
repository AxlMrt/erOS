{
  lib,
  pkgs,
  config,
  ...
}: let
  dnsByProfile = {
    system = [];
    cloudflare = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    quad9 = [
      "9.9.9.9"
      "149.112.112.112"
    ];
    mullvad = [
      "194.242.2.2"
      "194.242.2.3"
    ];
  };

  identityHostnameByProfile = {
    clean = "workstation";
    offensive = "opsec-node";
    lab = "lab-node";
  };

  dnsServers = dnsByProfile.${config.eros.opsec.dnsProfile} or [];

  vpnPackages =
    if config.eros.opsec.vpn.provider == "wireguard"
    then [pkgs.wireguard-tools]
    else if config.eros.opsec.vpn.provider == "openvpn"
    then [pkgs.openvpn pkgs.networkmanager-openvpn]
    else [pkgs.openvpn pkgs.wireguard-tools pkgs.networkmanager-openvpn];
in {
  options.eros.opsec = {
    enable = lib.mkEnableOption "opsec defaults and identity segregation";

    identityProfile = lib.mkOption {
      type = lib.types.enum [
        "clean"
        "offensive"
        "lab"
      ];
      default = "clean";
      description = "Identity profile to reduce cross-context fingerprint reuse.";
    };

    dnsProfile = lib.mkOption {
      type = lib.types.enum [
        "system"
        "cloudflare"
        "quad9"
        "mullvad"
      ];
      default = "quad9";
      description = "DNS hygiene profile.";
    };

    macSpoof.enable = lib.mkEnableOption "MAC randomization defaults for NetworkManager";

    vpn.provider = lib.mkOption {
      type = lib.types.enum [
        "auto"
        "wireguard"
        "openvpn"
      ];
      default = "auto";
      description = "VPN client stack policy for offensive contexts.";
    };

    vpn.openvpnConfigFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to OpenVPN client config (typically from sops secret path).";
    };

    vpn.wireguardConfigFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to WireGuard config file (typically from sops secret path).";
    };

    vpn.autoConnect.enable = lib.mkEnableOption "automatic VPN connection with systemd";

    vpn.autoConnect.unitName = lib.mkOption {
      type = lib.types.str;
      default = "eros-vpn";
      description = "Base systemd unit name used for VPN autoconnect.";
    };

    logging.minimal.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Keep logs useful but short-lived and bounded.";
    };
  };

  config = lib.mkIf config.eros.opsec.enable {
    assertions = [
      {
        assertion =
          !(config.eros.opsec.vpn.autoConnect.enable && config.eros.opsec.vpn.provider == "openvpn")
          || config.eros.opsec.vpn.openvpnConfigFile != null;
        message = "eros.opsec.vpn.openvpnConfigFile must be set when VPN autoconnect is enabled with openvpn provider.";
      }
      {
        assertion =
          !(config.eros.opsec.vpn.autoConnect.enable && config.eros.opsec.vpn.provider == "wireguard")
          || config.eros.opsec.vpn.wireguardConfigFile != null;
        message = "eros.opsec.vpn.wireguardConfigFile must be set when VPN autoconnect is enabled with wireguard provider.";
      }
    ];

    networking.hostName = lib.mkDefault identityHostnameByProfile.${config.eros.opsec.identityProfile};

    networking.networkmanager = {
      enable = lib.mkDefault true;
      dns = "systemd-resolved";
      wifi.scanRandMacAddress = lib.mkIf config.eros.opsec.macSpoof.enable true;
      wifi.macAddress = lib.mkIf config.eros.opsec.macSpoof.enable "random";
    };

    services.resolved = {
      enable = true;
      settings.Resolve = {
        DNSSEC = "allow-downgrade";
        DNSOverTLS = "opportunistic";
      };
    };

    networking.nameservers = lib.mkIf (dnsServers != []) dnsServers;

    environment.systemPackages = vpnPackages;

    environment.sessionVariables =
      lib.optionalAttrs (config.eros.opsec.vpn.openvpnConfigFile != null) {
        EROS_OPENVPN_CONFIG_FILE = config.eros.opsec.vpn.openvpnConfigFile;
      }
      // lib.optionalAttrs (config.eros.opsec.vpn.wireguardConfigFile != null) {
        EROS_WG_CONFIG_FILE = config.eros.opsec.vpn.wireguardConfigFile;
      };

    systemd.services =
      lib.optionalAttrs (config.eros.opsec.vpn.autoConnect.enable && config.eros.opsec.vpn.provider == "openvpn") {
        "${config.eros.opsec.vpn.autoConnect.unitName}-openvpn" = {
          description = "ErOS OpenVPN autoconnect";
          wantedBy = ["multi-user.target"];
          after = ["network-online.target"];
          wants = ["network-online.target"];
          serviceConfig = {
            Type = "forking";
            RuntimeDirectory = "eros-openvpn";
            PIDFile = "/run/eros-openvpn/openvpn.pid";
            ExecStart = "${pkgs.openvpn}/bin/openvpn --config ${config.eros.opsec.vpn.openvpnConfigFile} --auth-nocache --daemon --writepid /run/eros-openvpn/openvpn.pid";
            ExecStop = "${pkgs.coreutils}/bin/kill -TERM $MAINPID";
            Restart = "on-failure";
            RestartSec = 3;
          };
        };
      }
      // lib.optionalAttrs (config.eros.opsec.vpn.autoConnect.enable && config.eros.opsec.vpn.provider == "wireguard") {
        "${config.eros.opsec.vpn.autoConnect.unitName}-wireguard" = {
          description = "ErOS WireGuard autoconnect";
          wantedBy = ["multi-user.target"];
          after = ["network-online.target"];
          wants = ["network-online.target"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${pkgs.wireguard-tools}/bin/wg-quick up ${config.eros.opsec.vpn.wireguardConfigFile}";
            ExecStop = "${pkgs.wireguard-tools}/bin/wg-quick down ${config.eros.opsec.vpn.wireguardConfigFile}";
          };
        };
      };

    services.journald.extraConfig = lib.mkIf config.eros.opsec.logging.minimal.enable ''
      Storage=volatile
      RuntimeMaxUse=200M
      MaxRetentionSec=7day
    '';

    services.avahi.enable = false;
  };
}
