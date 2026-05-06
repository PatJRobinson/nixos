{...}: {
  # Configure nix-flatpak
  services.flatpak = {
    enable = true;
    packages = [
      "com.nomachine.nxplayer"
    ];
  };
}
