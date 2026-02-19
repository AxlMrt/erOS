{
  config,
  pkgs,
  ...
}: {
  programs.hyprland.enable = true;

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.hyprland}/bin/start-hyprland";
      user = "axlmrt";
    };
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  hardware.opengl.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  environment.systemPackages = with pkgs; [
    grim
    kitty
    slurp
    waybar
    wl-clipboard
    wofi
  ];
}
