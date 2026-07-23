#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -f /etc/arch-release ]; then
  echo "This script is for Arch Linux and Arch-based distros only."
  exit 1
fi

AUR_PACKAGES=(
  maplemono-nf-unhinted
  maplemono-ttf
  noto-fonts-emoji
  syshud
  noctalia
  adwaita-fonts
  fontconfig
  gnu-free-fonts
  lib32-fontconfig
  libfontenc
  libxfont2
  noto-fonts
  noto-fonts-cjk
  ttf-dejavu
  woff2-font-awesome
  xorg-fonts-encodings
  nwg-displays
  polkit-gnome
)

REPO_PACKAGES=(
  niri mako nwg-bar xwayland-satellite kitty sddm
  fish wl-clipboard git playerctl brightnessctl
  pipewire wireplumber pipewire-audio
  xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk
  qt6-base qt6-svg qt6-multimedia qt6-virtualkeyboard
  polkit-gnome network-manager-applet libnotify
  cliphist fastfetch
)

CONFIG_DIRS=(niri fish kitty fastfetch noctalia)

install_aur_helper() {
  local helper="$1"
  if command -v "$helper" &>/dev/null; then
    echo "[*] $helper already installed"
    return
  fi
  echo "[*] Installing $helper..."
  sudo pacman -S --needed --noconfirm base-devel git
  local tmpdir
  tmpdir="$(mktemp -d)"
  case "$helper" in
  yay)
    git clone https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin"
    (cd "$tmpdir/yay-bin" && makepkg -si --noconfirm)
    ;;
  paru)
    git clone https://aur.archlinux.org/paru-bin.git "$tmpdir/paru-bin"
    (cd "$tmpdir/paru-bin" && makepkg -si --noconfirm)
    ;;
  esac
  rm -rf "$tmpdir"
}

backup_and_deploy() {
  local src="$1"
  local dst="$2"
  local name
  name="$(basename "$src")"

  if [ -e "$dst" ]; then
    local backup="${dst}.bak.$(date +%Y%m%d-%H%M%S)"
    echo "[*] Backing up $dst -> $backup"
    mv "$dst" "$backup"
  fi

  echo "[*] Deploying $name -> $dst"
  cp -r "$src" "$dst"
}

echo "========================================"
echo "  noctari dotfiles installer"
echo "========================================"
echo ""

echo "Select AUR helper:"
echo "  1) yay"
echo "  2) paru"
read -rp "Choice [1/2]: " aur_choice

case "$aur_choice" in
1) AUR_HELPER="yay" ;;
2) AUR_HELPER="paru" ;;
*)
  echo "Invalid choice, defaulting to yay"
  AUR_HELPER="yay"
  ;;
esac

install_aur_helper "$AUR_HELPER"

echo ""
echo "[*] Installing repo packages..."
sudo pacman -S --needed --noconfirm "${REPO_PACKAGES[@]}"

echo "[*] Installing AUR packages..."
"$AUR_HELPER" -S --needed --noconfirm "${AUR_PACKAGES[@]}"

echo ""
echo "[*] Deploying configs..."
for dir in "${CONFIG_DIRS[@]}"; do
  src="$SCRIPT_DIR/$dir"
  dst="$HOME/.config/$dir"
  if [ -d "$src" ]; then
    backup_and_deploy "$src" "$dst"
  fi
done

echo ""
echo "[*] Deploying SDDM theme..."
sudo cp -rT "$SCRIPT_DIR/sddm/theme" /usr/share/sddm/themes/noctari
echo "[*] Deploying SDDM config..."
sudo mkdir -p /etc/sddm.conf.d
sudo cp "$SCRIPT_DIR/sddm/sddm.conf" /etc/sddm.conf.d/noctari.conf
sudo cp "$SCRIPT_DIR/sddm/virtualkbd.conf" /etc/sddm.conf.d/virtualkbd.conf 2>/dev/null || true

echo ""
echo "[*] Setting fish as default shell..."
FISH_PATH="$(which fish)"
if ! grep -qx "$FISH_PATH" /etc/shells; then
  echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
fi
chsh -s "$FISH_PATH"

echo "[*] Enabling sddm..."
sudo systemctl enable sddm 2>/dev/null || true

echo ""
echo "[*] Installation complete!"
echo "    Reboot or start sddm to enter the desktop."
