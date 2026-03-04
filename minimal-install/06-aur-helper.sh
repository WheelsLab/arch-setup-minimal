#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/constants.sh"
source "$SCRIPT_DIR/lib/logging.sh"
source "$SCRIPT_DIR/lib/utils.sh"

check_root
log_section "Installing AUR Helper (paru)"

MOUNT_ROOT="${MOUNT_POINT_ROOT}"

log_step "Installing base-devel if not present..."
arch-chroot "$MOUNT_ROOT" pacman -S --noconfirm base-devel git

log_step "Cloning and building paru..."
arch-chroot "$MOUNT_ROOT" /bin/bash -c '
    cd /tmp
    rm -rf paru
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
'

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
