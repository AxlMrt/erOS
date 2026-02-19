{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    assetfinder
    ffuf
    httpx
    nuclei
    subfinder
  ];
}
