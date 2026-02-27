{
  pkgs,
  hostname,
  username,
  ...
}: {
  networking.hostName = hostname;
  networking.hosts = {
    "10.129.6.40" = ["2million.htb"];
  };
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "fr_FR.UTF-8";

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "libvirtd"];
    shell = pkgs.zsh;
  };

  system.stateVersion = "25.11";
}
