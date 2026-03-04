#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/constants.sh"
source "$SCRIPT_DIR/lib/logging.sh"
source "$SCRIPT_DIR/lib/utils.sh"

check_root
log_section "Configuring Base System"

MOUNT_ROOT="${MOUNT_POINT_ROOT}"

log_step "Setting timezone..."
arch-chroot "$MOUNT_ROOT" ln -sf /usr/share/zoneinfo/UTC /etc/localtime

log_step "Generating locale..."
echo "en_US.UTF-8 UTF-8" >> "$MOUNT_ROOT/etc/locale.gen"
echo "zh_CN.UTF-8 UTF-8" >> "$MOUNT_ROOT/etc/locale.gen"
arch-chroot "$MOUNT_ROOT" locale-gen

log_step "Setting locale..."
echo "LANG=en_US.UTF-8" > "$MOUNT_ROOT/etc/locale.conf"

log_step "Setting hostname..."
read -rp "Enter hostname [archlinux]: " HOSTNAME
HOSTNAME="${HOSTNAME:-archlinux}"
echo "$HOSTNAME" > "$MOUNT_ROOT/etc/hostname"

log_step "Configuring vconsole..."
echo "KEYMAP=us" > "$MOUNT_ROOT/etc/vconsole.conf"
echo "FONT=ter-v16n" >> "$MOUNT_ROOT/etc/vconsole.conf"

log_step "Configuring mkinitcpio for LUKS..."
sed -i 's/HOOKS=(base udev)/HOOKS=(base udev autodetect microcode modconf block encrypt filesystems keyboard fsck)/' "$MOUNT_ROOT/etc/mkinitcpio.conf"

log_step "Regenerating initramfs..."
arch-chroot "$MOUNT_ROOT" mkinitcpio -P

log_step "Setting root password..."
arch-chroot "$MOUNT_ROOT" passwd

log_success "Base system configured!"
