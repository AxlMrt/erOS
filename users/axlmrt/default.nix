{username, ...}: {
  # Shared identity from flake specialArgs.
  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.stateVersion = "25.11";

  eros.theme.variant = "mocha";

  # User-level app enablement.
  programs.git.enable = true;

  imports = [
    ../../modules/home-manager
  ];
}
