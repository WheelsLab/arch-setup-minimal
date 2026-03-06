#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/constants.sh"
source "$SCRIPT_DIR/../lib/logging.sh"
source "$SCRIPT_DIR/../lib/utils.sh"

log_section "Bootloader Automation & Plymouth"

log_step "Getting root device from mount info..."
ROOT_DEVICE=$(findmnt -n -o SOURCE -T / | cut -d'[' -f1)
log_info "Root device: $ROOT_DEVICE"

log_step "Getting LUKS UUID..."
if [[ "$ROOT_DEVICE" == /dev/mapper/* ]]; then
    MAPPER_NAME=$(basename "$ROOT_DEVICE")
    log_info "Mapper name: $MAPPER_NAME"
    
    CRYPTSETUP_OUTPUT=$(sudo cryptsetup status "$MAPPER_NAME" 2>&1) || {
        log_error "Failed to get cryptsetup status for $MAPPER_NAME"
        log_error "$CRYPTSETUP_OUTPUT"
        exit 1
    }
    
    LUKS_PARTITION=$(echo "$CRYPTSETUP_OUTPUT" | grep -oP '/dev/\S+' | tail -1)
    log_info "LUKS partition: $LUKS_PARTITION"
    
    if [[ -z "$LUKS_PARTITION" ]]; then
        log_error "Could not extract LUKS partition from cryptsetup output"
        exit 1
    fi
    
    if ! sudo cryptsetup isLuks "$LUKS_PARTITION" 2>/dev/null; then
        log_error "Device $LUKS_PARTITION is not a LUKS container"
        exit 1
    fi
    
    LUKS_UUID=$(sudo blkid -s UUID -o value "$LUKS_PARTITION" 2>&1)
    if [[ -z "$LUKS_UUID" ]]; then
        log_error "Failed to get LUKS UUID from $LUKS_PARTITION"
        exit 1
    fi
    CRYPT_NAME="$MAPPER_NAME"
else
    log_error "Root device is not a LUKS container"
    exit 1
fi
log_info "LUKS UUID: $LUKS_UUID"
log_info "Crypt name: $CRYPT_NAME"

log_step "Installing limine-mkinitcpio-hook..."
retry_command 3 paru -S --noconfirm limine-mkinitcpio-hook

log_step "Configuring limine..."
if [[ ! -f /etc/default/limine ]]; then
    sudo cp /etc/limine-entry-tool.conf /etc/default/limine
fi

log_step "Updating limine configuration..."
sudo tee -a /etc/default/limine > /dev/null <<EOF
KERNEL_CMDLINE[default]=rd.luks.name=${LUKS_UUID}=${CRYPT_NAME} root=/dev/mapper/${CRYPT_NAME} rootflags=subvol=@ rootfstype=btrfs rw
TIMEOUT=5
ROOT_SUBVOLUME_PATH=/@
ROOT_SNAPSHOTS_PATH=/@snapshots
MAX_SNAPSHOT_ENTRIES=50
EOF

log_step "Installing limine-snapper-sync..."
retry_command 3 paru -S --noconfirm limine-snapper-sync

log_step "Configuring mkinitcpio for sd-btrfs-overlayfs..."
sudo sed -i '/^HOOKS=/ {
     s/\(filesystems\)\(.*sd-btrfs-overlayfs\)/\1 sd-btrfs-overlayfs/
     t
     s/\(filesystems\)/\1 sd-btrfs-overlayfs/
 }' /etc/mkinitcpio.conf

log_step "Running limine-install..."
sudo limine-install

log_step "Enabling limine-snapper-sync service..."
sudo systemctl enable --now limine-snapper-sync.service

log_step "Installing plymouth..."
sudo pacman -S --noconfirm plymouth

log_step "Configuring plymouth in limine..."
if ! grep -q 'splash quiet' /etc/default/limine; then
    sudo tee -a /etc/default/limine > /dev/null <<EOF
KERNEL_CMDLINE[default]+="splash quiet"
EOF
fi

log_step "Configuring mkinitcpio for plymouth..."
sudo sed -i '/^HOOKS=/ {
    s/\(.*sd-encrypt\)\(.*plymouth\)/\1 plymouth\2/
    t
    s/\(.*sd-encrypt\)/\1 plymouth/
}' /etc/mkinitcpio.conf

log_step "Regenerating initramfs with plymouth..."
sudo limine-mkinitcpio

log_success "Bootloader automation and Plymouth configured!"
