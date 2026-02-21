{
  config,
  pkgs,
  ...
}: {
  imports = [];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";

  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

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
