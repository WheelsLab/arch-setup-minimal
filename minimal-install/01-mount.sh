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
    echo -n "$PASSWORD" | cryptsetup open "/dev/disk/by-label/archsystem" "$CRYPT_NAME" -
fi

log_step "Mounting Btrfs subvolumes..."
mount -o subvol=@ "/dev/mapper/$CRYPT_NAME" "$MOUNT_ROOT"
mount -o subvol=@home "/dev/mapper/$CRYPT_NAME" "$MOUNT_ROOT/home"
mount -o subvol=@log "/dev/mapper/$CRYPT_NAME" "$MOUNT_ROOT/var/log"
mount -o subvol=@cache "/dev/mapper/$CRYPT_NAME" "$MOUNT_ROOT/var/cache"
mount -o subvol=@snapshots "/dev/mapper/$CRYPT_NAME" "$MOUNT_ROOT/.snapshots"

log_step "Mounting ESP..."
mount "/dev/disk/by-partuuid=$(blkid -s PARTUUID -o value ${DISK:-/dev/sda}1)" "$MOUNT_ROOT/boot" 2>/dev/null || \
    mount "/dev/disk/by-label/EFI" "$MOUNT_ROOT/boot" 2>/dev/null || \
    mount "$MOUNT_ROOT/boot"

log_success "Filesystems mounted at $MOUNT_ROOT"
