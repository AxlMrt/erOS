{
  pkgs,
  hostname,
  username,
  ...
}: {
  networking.hostName = hostname;
  networking.hosts = {
    "10.129.3.107" = ["wingdata.htb" "ftp.wingdata.htb"];
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
