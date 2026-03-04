#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/constants.sh"
source "$SCRIPT_DIR/lib/logging.sh"
source "$SCRIPT_DIR/lib/utils.sh"

check_root

log_section "Mounting Filesystems"

MOUNT_ROOT="${MOUNT_POINT_ROOT}"
CRYPT_NAME="${LUKS_CONTAINER_NAME}"

if is_mounted "$MOUNT_ROOT"; then
    log_info "Filesystems already mounted at $MOUNT_ROOT"
    log_success "Skipping mount step"
    exit 0
fi

log_step "Ensuring mount points exist..."
create_directories \
    "$MOUNT_ROOT/home" \
    "$MOUNT_ROOT/boot" \
    "$MOUNT_ROOT/var/log" \
    "$MOUNT_ROOT/var/cache" \
    "$MOUNT_ROOT/.snapshots"

log_step "Opening LUKS container..."
if ! cryptsetup isActive "$CRYPT_NAME" 2>/dev/null; then
    read -rsp "Enter LUKS password: " PASSWORD
    echo
    LUKS_PART=$(lsblk -ln -o NAME,TYPE | awk '$2=="part"{print "/dev/"$1}' | head -1)
    echo -n "$PASSWORD" | cryptsetup open "$LUKS_PART" "$CRYPT_NAME" -
fi

log_step "Mounting Btrfs subvolumes..."
mount -o subvol=@ "/dev/mapper/$CRYPT_NAME" "$MOUNT_ROOT"
mount -o subvol=@home "/dev/mapper/$CRYPT_NAME" "$MOUNT_ROOT/home"
mount -o subvol=@log "/dev/mapper/$CRYPT_NAME" "$MOUNT_ROOT/var/log"
mount -o subvol=@cache "/dev/mapper/$CRYPT_NAME" "$MOUNT_ROOT/var/cache"
mount -UNT_ROOT/varo subvol=@snapshots "/dev/mapper/$CRYPT_NAME" "$MOUNT_ROOT/.snapshots"

log_step "Mounting ESP..."
ESP_PART=$(lsblk -ln -o NAME,TYPE | awk 'NR==2{print "/dev/"$1}')
mount "$ESP_PART" "$MOUNT_ROOT/boot"

log_success "Filesystems mounted at $MOUNT_ROOT"
