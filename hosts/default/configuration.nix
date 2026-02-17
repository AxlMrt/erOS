{ config, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core/system.nix
    ../../modules/desktop/hyprland.nix
    ../../modules/security/base-tools.nix
    ../../modules/security/recon.nix
    ../../modules/security/web.nix
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
