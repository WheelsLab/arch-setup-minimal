#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/constants.sh"
source "$SCRIPT_DIR/lib/logging.sh"
source "$SCRIPT_DIR/lib/utils.sh"

check_root
log_section "Installing Base Packages"

MOUNT_ROOT="${MOUNT_POINT_ROOT}"

PACKAGES=(
    base
    linux
    linux-firmware
    linux-headers
    intel-ucode
    amd-ucode
    btrfs-progs
    networkmanager
    vim
    man-db
    man-pages
    texinfo
    base-devel
    git
    wget
    curl
    reflector
)

log_step "Running pacstrap..."
pacstrap -K "${MOUNT_ROOT}" "${PACKAGES[@]}"

log_step "Generating fstab..."
if is_uefi; then
    genfstab -U -p "$MOUNT_ROOT" >> "$MOUNT_ROOT/etc/fstab"
else
    genfstab -U "$MOUNT_ROOT" >> "$MOUNT_ROOT/etc/fstab"
fi

log_success "Base packages installed!"
