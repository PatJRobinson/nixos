{
  pkgs,
  foreground,
  outline,
}:
pkgs.runCommand "softlight-purple-cursor" {
  nativeBuildInputs = [pkgs.python3 pkgs.librsvg pkgs.xcursorgen];
} ''
  python3 ${./build-cursor.py} \
    ${pkgs.rose-pine-hyprcursor}/share/icons/rose-pine-hyprcursor \
    "$out/share/icons/Softlight-Purple" '#${foreground}' '#${outline}'
''
