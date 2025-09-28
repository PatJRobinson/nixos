# taken from dotfiles at https://github.com/patjrobinson/waybartheme.git
{ waybarParams, ... }:
let
  params = waybarParams;
in {
  programs.waybar = {
    enable = true;
  };
}
