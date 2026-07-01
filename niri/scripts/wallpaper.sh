#!/usr/bin/env bash
set -e

WALL_DIR="$HOME/Pictures/wallpapers"

CENTER="$HOME/Pictures/background_temp/current.png"
HYPRLOCK="$HOME/.config/hypr/hyprlock.png"
ROFI="$HOME/.config/rofi/.current_wallpaper"

mkdir -p "$(dirname "$CENTER")"
mkdir -p "$(dirname "$HYPRLOCK")"
mkdir -p "$(dirname "$ROFI")"

# rofi gallery
CHOICE=$(find "$WALL_DIR" -maxdepth 1 -type f \( \
  -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) |
  sort |
  while read -r img; do
    name="$(basename "$img")"
    printf "%s\x00icon\x1f%s\n" "$name" "$img"
  done |
  rofi -dmenu -i -show-icons -p "🌱 Wallpaper" \
    -theme-str '
      element-icon { size: 256px; }
      listview { columns: 3; lines: 3; }
      window { width: 60%; }
    ')

[ -z "$CHOICE" ] && exit 0

IMG="$WALL_DIR/$CHOICE"

# nếu tồn tại file thường → xoá
for f in "$CENTER" "$HYPRLOCK" "$ROFI"; do
  if [ -e "$f" ] && [ ! -L "$f" ]; then
    rm -f "$f"
  fi
done

# symlink background
ln -sf "$IMG" "$CENTER"
ln -sf "$CENTER" "$HYPRLOCK"
ln -sf "$CENTER" "$ROFI"

if ! pgrep -x swww-daemon >/dev/null; then
  swww-daemon &
  sleep 0.2
fi

# set wallpaper for niri
awww img "$CENTER" \
  --transition-type grow \
  --transition-duration 0.6 \
  --transition-fps 60
# gen colorscheme
wal -i "$IMG"

#reload noctalia
# pkill qs || true
# sleep 0.5 # Chờ một chút để Noctalia kịp đóng hẳn
# qs -c noctalia-shell &
# reload hyprlock
pkill -USR1 hyprlock 2>/dev/null || true
