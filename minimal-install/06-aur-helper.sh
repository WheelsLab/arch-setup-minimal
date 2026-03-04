#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/constants.sh"
source "$SCRIPT_DIR/lib/logging.sh"
source "$SCRIPT_DIR/lib/utils.sh"

check_root
log_section "Installing AUR Helper (paru)"

MOUNT_ROOT="${MOUNT_POINT_ROOT}"
AUR_DIR="/tmp/paru"
AUR_BIN="/usr/local/bin/paru"

log_step "Installing base-devel if not present..."
arch-chroot "$MOUNT_ROOT" pacman -S --noconfirm base-devel

log_step "Cloning paru..."
rm -rf "$AUR_DIR"
git clone https://aur.archlinux.org/paru.git "$AUR_DIR"

log_step "Building paru..."
cd "$AUR_DIR"
arch-chroot "$MOUNT_ROOT" /bin/bash -c "cd /tmp/paru && makepkg -si --noconfirm"

log_step "Configuring paru..."
mkdir -p "$MOUNT_ROOT/etc/paru"
cat > "$MOUNT_ROOT/etc/paru.conf" <<'EOF'
[options]
BotUpdate = false
DiffViewer = less
RemoveMake = true
UpgradeMenu = true

[bin]
PkgList = pacman -Qq
EOF

log_success "paru installed!"
