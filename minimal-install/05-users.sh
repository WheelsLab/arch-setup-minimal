#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/constants.sh"
source "$SCRIPT_DIR/lib/logging.sh"
source "$SCRIPT_DIR/lib/utils.sh"

check_root
log_section "Creating Users"

MOUNT_ROOT="${MOUNT_POINT_ROOT}"

log_step "Creating sudo group..."
arch-chroot "$MOUNT_ROOT" groupadd sudo || true

log_step "Creating user..."
read -rp "Enter username: " USERNAME
[[ -z "$USERNAME" ]] && log_error "Username required" && exit 1

if ! arch-chroot "$MOUNT_ROOT" id "$USERNAME" 2>/dev/null; then
    arch-chroot "$MOUNT_ROOT" useradd -m -G wheel,sudo -s /bin/bash "$USERNAME"
    log_info "User '$USERNAME' created"
else
    log_info "User '$USERNAME' already exists"
fi

log_step "Setting user password..."
arch-chroot "$MOUNT_ROOT" passwd "$USERNAME"

log_step "Configuring sudo..."
echo "%wheel ALL=(ALL) ALL" > "$MOUNT_ROOT/etc/sudoers.d/wheel"
chmod 440 "$MOUNT_ROOT/etc/sudoers.d/wheel"

log_success "User setup completed!"
