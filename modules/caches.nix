# /etc/nixos/modules/caches.nix
{
  config,
  pkgs,
  lib,
  ...
}: {
  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://ros.cachix.org"
      "http://192.168.2.10:5000"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo="
      "cache.lan-1:wl1EkrxGAps6aNJbgiYdfz5LCRVgu9zny7BksuCW2AQ="
    ];
  };
}
