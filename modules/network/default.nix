{
  lib,
  pkgs,
  config,
  ...
}: let
  profile = config.eros.network.profile;
  tcpByProfile = {
    trusted = [22 80 443];
    untrusted = [22];
    engagement = [22];
    isolated-offensive = [];
    lab = [22 5900 3389];
  };
  udpByProfile = {
    trusted = [];
    untrusted = [];
    engagement = [];
    isolated-offensive = [];
    lab = [53 67 68];
  };

  closePortScript = pkgs.writeShellScript "eros-port-close" ''
    set -euo pipefail
    proto="$1"
    port="$2"
    tag="eros-temp-$proto-$port"

    ${pkgs.nftables}/bin/nft -a list chain inet nixos-fw input | ${pkgs.gnugrep}/bin/grep "$tag" | ${pkgs.gawk}/bin/awk '{print $NF}' | while read -r handle; do
      ${pkgs.nftables}/bin/nft delete rule inet nixos-fw input handle "$handle"
    done || true
  '';

  portctl = pkgs.writeShellApplication {
    name = "eros-portctl";
    runtimeInputs = with pkgs; [bash coreutils gnugrep gawk nftables systemd];
    text = ''
      set -euo pipefail

      usage() {
        echo "Usage: eros-portctl open <tcp|udp> <port> <ttl-seconds>"
        echo "       eros-portctl close <tcp|udp> <port>"
      }

      if [[ $# -lt 3 ]]; then
        usage
        exit 1
      fi

      cmd="$1"
      proto="$2"
      port="$3"
      tag="eros-temp-$proto-$port"

      close_rule() {
        ${closePortScript} "$proto" "$port"
      }

      case "$cmd" in
        open)
          if [[ $# -ne 4 ]]; then
            usage
            exit 1
          fi
          ttl="$4"
          nft add rule inet nixos-fw input "$proto" dport "$port" counter accept comment "$tag"
          systemd-run --unit "eros-close-$proto-$port" --on-active "''${ttl}s" \
            ${closePortScript} "$proto" "$port" >/dev/null
          ;;
        close)
          close_rule
          ;;
        *)
          usage
          exit 1
          ;;
      esac
    '';
  };
in {
  options.eros.network = {
    profile = lib.mkOption {
      type = lib.types.enum [
        "trusted"
        "untrusted"
        "engagement"
        "isolated-offensive"
        "lab"
      ];
      default = "untrusted";
      description = "Network exposure profile used for firewall defaults.";
    };

    extraAllowedTCP = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [];
      description = "Additional TCP ports allowed by policy.";
    };

    extraAllowedUDP = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [];
      description = "Additional UDP ports allowed by policy.";
    };

    tempPorts.enable = lib.mkEnableOption "temporary runtime port opening helper";
  };

  config = {
    networking.nftables.enable = true;

    networking.firewall = {
      enable = true;
      allowedTCPPorts = (tcpByProfile.${profile} or []) ++ config.eros.network.extraAllowedTCP;
      allowedUDPPorts = (udpByProfile.${profile} or []) ++ config.eros.network.extraAllowedUDP;
      logReversePathDrops = true;
      allowPing = lib.mkDefault false;
    };

    environment.systemPackages = lib.mkIf config.eros.network.tempPorts.enable [portctl];
  };
}
