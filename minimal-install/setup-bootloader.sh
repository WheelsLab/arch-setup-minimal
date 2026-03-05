#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/constants.sh"
source "$SCRIPT_DIR/../lib/logging.sh"
source "$SCRIPT_DIR/../lib/utils.sh"

check_root
log_section "Installing Limine Bootloader"

MOUNT_ROOT="/mnt"

if ! [[ -d /sys/firmware/efi ]]; then
    log_error "Limine requires UEFI boot mode"
    exit 1
fi

DISK="${DISK:-/dev/vda}"
ESP_PART="${DISK}p1"
[[ ! -b "${DISK}p1" ]] && ESP_PART="${DISK}1"
SYSTEM_PART="${DISK}p2"
[[ ! -b "${DISK}p2" ]] && SYSTEM_PART="${DISK}2"
CRYPT_NAME="cryptsystem"

log_step "Installing Limine and efibootmgr..."
arch-chroot "$MOUNT_ROOT" pacman -S --noconfirm limine efibootmgr

log_step "Deploying Limine UEFI..."
EFI_DIR="$MOUNT_ROOT/boot/EFI/arch-limine"
mkdir -p "$EFI_DIR"
cp "$MOUNT_ROOT/usr/share/limine/BOOTX64.EFI" "$EFI_DIR/"

log_step "Configuring mkinitcpio for LUKS and Btrfs..."
sed -i 's/^HOOKS=(.*)/HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck)/' "$MOUNT_ROOT/etc/mkinitcpio.conf"

touch "$MOUNT_ROOT/etc/vconsole.conf"

log_step "Regenerating initramfs..."
arch-chroot "$MOUNT_ROOT" mkinitcpio -P

log_step "Getting LUKS UUID..."
LUKS_UUID=$(blkid -s UUID -o value "$SYSTEM_PART")
log_info "LUKS UUID: $LUKS_UUID"

log_step "Creating Limine configuration..."
cat > "$MOUNT_ROOT/etc/limine.cfg" <<EOF
timeout: 5

/Arch Linux
    protocol: linux
    path: boot():/vmlinuz-linux
    cmdline: rd.luks.name=${LUKS_UUID}=${CRYPT_NAME} root=/dev/mapper/${CRYPT_NAME} rootflags=subvol=@ rootfstype=btrfs rw
    module_path: boot():/initramfs-linux.img
EOF

log_step "Creating UEFI boot entry..."
arch-chroot "$MOUNT_ROOT" efibootmgr \
    --create \
    --disk "$DISK" \
    --part 1 \
    --label "Arch Linux Limine Boot Loader" \
    --loader '\EFI\arch-limine\BOOTX64.EFI' \
    --unicode

log_success "Limine bootloader installed!"
log_info "You can now reboot into your new Arch Linux system"
