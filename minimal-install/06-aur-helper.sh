#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/constants.sh"
source "$SCRIPT_DIR/lib/logging.sh"
source "$SCRIPT_DIR/lib/utils.sh"

check_root
log_section "Installing AUR Helper (paru)"

MOUNT_ROOT="${MOUNT_POINT_ROOT}"

log_step "Installing base-devel, git and go..."
arch-chroot "$MOUNT_ROOT" pacman -S --noconfirm base-devel git go

log_step "Installing paru from AUR..."
arch-chroot "$MOUNT_ROOT" /bin/bash -c '
    cd /tmp
    rm -rf paru-bin
    git clone --depth 1 https://aur.archlinux.org/paru-bin.git
    cd paru-bin
    makepkg --nobuild --nosign --noconfirm
    pacman -U --noconfirm paru-*.pkg.tar.zst
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
