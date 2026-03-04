#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/constants.sh"
source "$SCRIPT_DIR/lib/logging.sh"
source "$SCRIPT_DIR/lib/utils.sh"

check_root
log_section "Installing Limine Bootloader"

MOUNT_ROOT="${MOUNT_POINT_ROOT}"

if ! is_uefi; then
    log_error "Limine requires UEFI boot mode"
    exit 1
fi

log_step "Installing Limine..."
arch-chroot "$MOUNT_ROOT" pacman -S --noconfirm limine

log_step "Configuring Limine..."
ROOT_UUID=$(blkid -s UUID -o value /dev/mapper/cryptroot)
ESP_PART="${MOUNT_ROOT}/boot"

cat > "$ESP_PART/limine.cfg" <<EOF
TIMEOUT=5

:Arch Linux
    PROTOCOL=limine
    KERNEL_PATH=boot:///vmlinuz-linux
    INITRD_PATH=boot:///intel-ucode.img
    CMDLINE=quiet loglevel=3 cryptdevice=UUID=$ROOT_UUID:cryptroot root=/dev/mapper/cryptroot
    MODULE_PATH=boot:///initramfs-linux.img
EOF

log_step "Installing Limine to ESP..."
ESP_DEVICE=$(lsblk -no pkname /dev/mapper/cryptroot 2>/dev/null || lsblk -no pkname /dev/vda2)
arch-chroot "$MOUNT_ROOT" limine bios-install "/dev/$ESP_DEVICE"

log_success "Limine bootloader installed!"
