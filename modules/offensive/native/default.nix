{
  lib,
  pkgs,
  config,
  ...
}: let
  defaultNativeTools = with pkgs; [
    bind
    curl
    dnsutils
    jq
    nmap
    openssl
    tcpdump
    whois
  ];
in {
  options.eros.offensive.native = {
    enable = lib.mkEnableOption "minimal offensive native toolset";
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = defaultNativeTools;
      description = "Native tools kept on the base system for daily workflows.";
    };
  };

  config = lib.mkIf config.eros.offensive.native.enable {
    environment.systemPackages = config.eros.offensive.native.packages;
  };
}
