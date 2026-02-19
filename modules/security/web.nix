{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    burpsuite
    chromium
    sqlmap
  ];
}
