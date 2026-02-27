{...}: {
  # Core system baseline shared by hosts.
  imports = [
    ./fonts.nix
    ./packages.nix
    ./system.nix
  ];
}
