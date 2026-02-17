{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  environment.systemPackages = with pkgs; [
    openvpn
    networkmanager-openvpn
  ];

  services.openvpn.servers = {};
}
