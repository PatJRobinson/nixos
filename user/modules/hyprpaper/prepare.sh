# Called by ExecStartPre: Hyprpaper reads the selected image from its initial
# configuration, so startup and automatic restarts need no IPC readiness loop.
wallpaper_dir="$1"
config_path="$2"

mapfile -d '' wallpapers < <(
  find -L "$wallpaper_dir" -type f \
    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \
       -o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.svg' \
       -o -iname '*.jxl' -o -iname '*.avif' \) -print0
)

if (( ${#wallpapers[@]} == 0 )); then
  echo "No wallpaper images found in $wallpaper_dir" >&2
  exit 1
fi

index=$(shuf -i "0-$((${#wallpapers[@]} - 1))" -n 1)
wallpaper="${wallpapers[$index]}"

umask 077
cat > "$config_path" <<EOF
wallpaper {
    monitor =
    path = $wallpaper
    fit_mode = cover
}
EOF

echo "Hyprpaper startup wallpaper: $wallpaper"
