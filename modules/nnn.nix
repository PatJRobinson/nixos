{ pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    imv
    bat
    jump
  ];

}
