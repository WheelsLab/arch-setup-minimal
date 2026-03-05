#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/constants.sh"
source "$SCRIPT_DIR/../lib/logging.sh"
source "$SCRIPT_DIR/../lib/utils.sh"

check_root
log_section "Installing Base Packages"

MOUNT_ROOT="/mnt"

log_step "Configuring Chinese mirrorlist..."
curl -L 'https://archlinux.org/mirrorlist/?country=CN&protocol=https' -o /tmp/mirrorlist
sed -i 's/^#Server/Server/' /tmp/mirrorlist
cp /tmp/mirrorlist "$MOUNT_ROOT/etc/pacman.d/mirrorlist"

log_step "Running pacstrap..."
pacstrap -K "$MOUNT_ROOT" \
    base \
    linux \
    linux-firmware \
    intel-ucode \
    btrfs-progs \
    networkmanager \
    vim \
    man-db \
    man-pages \
    texinfo

log_step "Generating fstab..."
genfstab -U "$MOUNT_ROOT" >> "$MOUNT_ROOT/etc/fstab"

log_step "Adjusting /boot mount in fstab..."
ESP_UUID=$(blkid -s UUID -o value "${DISK:-/dev/vda}p1")
if [[ -n "$ESP_UUID" ]]; then
    sed -i "s|^.*/boot.*|UUID=$ESP_UUID          /boot           vfat            rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro      0 2|" "$MOUNT_ROOT/etc/fstab"
fi

log_success "Base packages installed!"
