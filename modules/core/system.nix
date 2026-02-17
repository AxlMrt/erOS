{ config, pkgs, ...}:

{
  imports = [];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";

  networking.networkmanager.enable = true;

  programs.zsh.enable = true;

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    curl
    git
    tmux
    vim
    wget
  ];
}
