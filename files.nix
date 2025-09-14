{ pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    syncthing
    nautilus
    nnn
    dua
    ncdu
  ];
}
