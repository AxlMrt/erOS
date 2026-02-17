{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gobuster
    john
    nmap
    tcpdump
  ];
}
