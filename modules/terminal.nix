{ pkgs, ...}:

{
  users.defaultUserShell = pkgs.zsh;

  programs = {
    zsh.enable = true; 
  };

  environment.systemPackages = with pkgs; [
    wl-clipboard
    ghostty
    wget
    git
    jq
    unzip
    lm_sensors
  ];
}
