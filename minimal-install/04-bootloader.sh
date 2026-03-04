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

log_step "Installing Limine and efibootmgr..."
arch-chroot "$MOUNT_ROOT" pacman -S --noconfirm limine efibootmgr

log_step "Deploying Limine UEFI..."
EFI_DIR="$MOUNT_ROOT/boot/EFI/arch-limine"
mkdir -p "$EFI_DIR"
cp /usr/share/limine/BOOTX64.EFI "$EFI_DIR/"

log_step "Configuring Limine..."
ROOT_UUID=$(blkid -s UUID -o value /dev/mapper/cryptroot)

cat > "$MOUNT_ROOT/boot/limine.cfg" <<EOF
TIMEOUT=5

:Arch Linux
    PROTOCOL=limine
    KERNEL_PATH=boot:///vmlinuz-linux
    INITRD_PATH=boot:///intel-ucode.img
    CMDLINE=quiet loglevel=3 cryptdevice=UUID=$ROOT_UUID:cryptroot root=/dev/mapper/cryptroot
    MODULE_PATH=boot:///initramfs-linux.img
EOF

log_step "Creating UEFI boot entry..."
arch-chroot "$MOUNT_ROOT" efibootmgr --create --disk /dev/vda --part 1 --label "Arch Linux Limine" --loader '\EFI\arch-limine\BOOTX64.EFI'

log_success "Limine bootloader installed!"
