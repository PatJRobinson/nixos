{lib, ...}: let
  srcDir = ./application-shortcuts;

  desktopFiles =
    builtins.filter (n: lib.hasSuffix ".desktop" n)
    (builtins.attrNames (builtins.readDir srcDir));

  mkEntry = name: {
    name = ".local/share/applications/${name}";
    value.source = srcDir + "/${name}";
  };
in {
  home.file = lib.listToAttrs (map mkEntry desktopFiles);
}
