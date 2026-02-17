{ config, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "axlmrt-laptop";

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "fr_FR.UTF-8";

  users.users.axlmrt = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
    shell = pkgs.zsh;
  };

  system.stateVersion = "25.11";
}
