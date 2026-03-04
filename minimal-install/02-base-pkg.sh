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

MAX_RETRIES=3
RETRY_COUNT=0

log_step "Running pacstrap with retry..."
while [[ $RETRY_COUNT -lt $MAX_RETRIES ]]; do
    if pacstrap -K "${MOUNT_ROOT}" "${PACKAGES[@]}"; then
        log_success "Base packages installed!"
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [[ $RETRY_COUNT -lt $MAX_RETRIES ]]; then
            log_warn "pacstrap failed. Retrying ($RETRY_COUNT/$MAX_RETRIES) in 5 seconds..."
            sleep 5
        else
            log_error "pacstrap failed after $MAX_RETRIES attempts"
            exit 1
        fi
    fi
done

log_step "Generating fstab..."
if is_uefi; then
    genfstab -U -p "$MOUNT_ROOT" >> "$MOUNT_ROOT/etc/fstab"
else
    genfstab -U "$MOUNT_ROOT" >> "$MOUNT_ROOT/etc/fstab"
fi

log_success "Base packages installed!"
