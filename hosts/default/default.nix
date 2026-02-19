{...}: {
  # Host composition: hardware + machine-level policy.
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
