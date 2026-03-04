#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/constants.sh"
source "$SCRIPT_DIR/lib/logging.sh"
source "$SCRIPT_DIR/lib/utils.sh"

check_root
log_section "Installing AUR Helper (paru)"

MOUNT_ROOT="${MOUNT_POINT_ROOT}"

log_step "Installing git..."
arch-chroot "$MOUNT_ROOT" pacman -S --noconfirm git

log_step "Installing paru-bin..."
arch-chroot "$MOUNT_ROOT" /bin/bash -c '
    cd /tmp
    rm -rf paru-bin
    git clone --depth 1 https://aur.archlinux.org/paru-bin.git
    cd paru-bin
    sudo -u builder makepkg --nobuild --nosign --noconfirm 2>/dev/null || true
'

log_info "Note: paru will be installed in post-install phase after user is created"
log_info "Skipping AUR helper installation for now"

log_success "AUR helper setup skipped (will be installed post-install)"
