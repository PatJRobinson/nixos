{pkgs, ...}: let
  hyprSession = pkgs.stdenvNoCC.mkDerivation {
    pname = "hyprland-wayland-session";
    version = "1";
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/share/wayland-sessions
      cat > $out/share/wayland-sessions/hyprland.desktop <<'EOF'
      [Desktop Entry]
      Name=Hyprland
      Comment=Dynamic tiling Wayland compositor
      Type=Application
      Exec=${pkgs.hyprland}/bin/start-hyprland
      TryExec=${pkgs.hyprland}/bin/start-hyprland
      DesktopNames=Hyprland
      EOF
    '';

    # This is the critical bit NixOS requires for sessionPackages:
    passthru.providedSessions = ["hyprland"];
  };
in {
  services.displayManager.sessionPackages = [hyprSession];
}
