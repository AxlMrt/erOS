{
  config,
  pkgs,
  ...
}: {
  # NetworkManager is enabled in modules/core/system.nix.
  networking.firewall.enable = true;

  environment.systemPackages = with pkgs; [
    openvpn
    networkmanager-openvpn
  ];

  services.openvpn.servers = {};
}
