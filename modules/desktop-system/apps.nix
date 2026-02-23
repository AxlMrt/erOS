{
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs;
    [
      firefox
    ]
    ++ lib.optionals (pkgs ? burpsuite) [
      burpsuite
    ];
}
