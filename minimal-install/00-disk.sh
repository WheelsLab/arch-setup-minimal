#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/constants.sh"
source "$SCRIPT_DIR/lib/logging.sh"
source "$SCRIPT_DIR/lib/utils.sh"

check_root
log_section "Disk Partitioning: LUKS + Btrfs"

log_warn "WARNING: This script will completely wipe the selected disk!"

echo "Available disks:"
lsblk -d -o NAME,SIZE,MODEL,TYPE | grep disk

read -rp "Enter the target disk (e.g., /dev/vda): " DISK

if [[ ! -b "$DISK" ]]; then
    log_error "Disk $DISK does not exist"
    exit 1
fi

echo "Current partitions on $DISK:"
lsblk "$DISK"

log_warn "About to wipe and repartition $DISK!"
read -rp "Type 'YES' to confirm: " CONFIRM
[[ "$CONFIRM" != "YES" ]] && log_error "Aborted" && exit 0

read -rsp "Enter LUKS password: " LUKS_PASSWORD
echo

read -rp "Enter username for encryption keyfile (optional, press Enter to skip): " KEY_USER
[[ -z "$KEY_USER" ]] && USE_KEYFILE=false || USE_KEYFILE=true

log_section "Configuring"

log_step "Checking for existing mounts..."
if mountpoint -q "$MOUNT_POINT_ROOT" 2>/dev/null; then
    log_warn "Unmounting existing mounts on $MOUNT_POINT_ROOT..."
    umount -R "$MOUNT_POINT_ROOT" 2>/dev/null || true
fi

if cryptsetup isActive "$LUKS_CONTAINER_NAME" 2>/dev/null; then
    log_warn "Closing existing LUKS container..."
    cryptsetup close "$LUKS_CONTAINER_NAME" 2>/dev/null || true
fi

ESP_SIZE="512M"
CRYPT_NAME="${LUKS_CONTAINER_NAME}"
BTRFS_LABEL="archsystem"

log_step "Wiping disk..."
sgdisk --zap-all "$DISK"
wipefs -a "$DISK"

log_step "Creating GPT partitions..."
sgdisk -n1:0:+$ESP_SIZE -t1:EF00 "$DISK"
sgdisk -n2:0:0 -t2:8300 "$DISK"
partprobe "$DISK"

ESP_PART="${DISK}p1"
[[ ! -b "${DISK}p1" ]] && ESP_PART="${DISK}1"
SYSTEM_PART="${DISK}p2"
[[ ! -b "${DISK}p2" ]] && SYSTEM_PART="${DISK}2"

log_info "ESP: $ESP_PART, System: $SYSTEM_PART"

log_step "Formatting ESP..."
mkfs.fat -F32 "$ESP_PART"

log_step "Setting up LUKS..."
echo -n "$LUKS_PASSWORD" | cryptsetup luksFormat "$SYSTEM_PART" -
echo -n "$LUKS_PASSWORD" | cryptsetup open "$SYSTEM_PART" "$CRYPT_NAME" -

log_step "Creating Btrfs filesystem..."
mkfs.btrfs -L "$BTRFS_LABEL" "/dev/mapper/$CRYPT_NAME"

log_step "Mounting top-level Btrfs..."
mount --mkdir "/dev/mapper/$CRYPT_NAME" "$MOUNT_POINT_ROOT"

log_step "Creating subvolumes..."
btrfs subvolume create "$MOUNT_POINT_ROOT/@"
btrfs subvolume create "$MOUNT_POINT_ROOT/@home"
btrfs subvolume create "$MOUNT_POINT_ROOT/@snapshots"
btrfs subvolume create "$MOUNT_POINT_ROOT/@log"
btrfs subvolume create "$MOUNT_POINT_ROOT/@cache"
btrfs subvolume create "$MOUNT_POINT_ROOT/@var_tmp"

log_info "Creating nested subvolumes..."
btrfs subvolume create "$MOUNT_POINT_ROOT/@vm"
btrfs subvolume create "$MOUNT_POINT_ROOT/@vm/@libvirt"
btrfs subvolume create "$MOUNT_POINT_ROOT/@vm/@qemu"
btrfs subvolume create "$MOUNT_POINT_ROOT/@container"
btrfs subvolume create "$MOUNT_POINT_ROOT/@container/@docker"
btrfs subvolume create "$MOUNT_POINT_ROOT/@container/@podman"

log_step "Unmounting top-level..."
umount "$MOUNT_POINT_ROOT"

log_step "Mounting subvolumes..."
mount -o subvol=@ --mkdir "/dev/mapper/$CRYPT_NAME" "$MOUNT_POINT_ROOT"
mount -o subvol=@home --mkdir "/dev/mapper/$CRYPT_NAME" "$MOUNT_POINT_ROOT/home"
mount -o subvol=@snapshots --mkdir "/dev/mapper/$CRYPT_NAME" "$MOUNT_POINT_ROOT/.snapshots"
mount -o subvol=@log --mkdir "/dev/mapper/$CRYPT_NAME" "$MOUNT_POINT_ROOT/var/log"
mount -o subvol=@cache --mkdir "/dev/mapper/$CRYPT_NAME" "$MOUNT_POINT_ROOT/var/cache"
mount -o subvol=@var_tmp --mkdir "/dev/mapper/$CRYPT_NAME" "$MOUNT_POINT_ROOT/var/tmp"

mount -o subvol=@vm/@libvirt --mkdir "/dev/mapper/$CRYPT_NAME" "$MOUNT_POINT_ROOT/var/lib/libvirt"
mount -o subvol=@vm/@qemu --mkdir "/dev/mapper/$CRYPT_NAME" "$MOUNT_POINT_ROOT/var/lib/qemu"
mount -o subvol=@container/@docker --mkdir "/dev/mapper/$CRYPT_NAME" "$MOUNT_POINT_ROOT/var/lib/docker"
mount -o subvol=@container/@podman --mkdir "/dev/mapper/$CRYPT_NAME" "$MOUNT_POINT_ROOT/var/lib/containers"

log_step "Disabling CoW on high I/O subvolumes..."
for dir in "$MOUNT_POINT_ROOT/var/lib/libvirt" "$MOUNT_POINT_ROOT/var/lib/qemu" \
           "$MOUNT_POINT_ROOT/var/lib/docker" "$MOUNT_POINT_ROOT/var/lib/containers"; do
    chattr +C "$dir" 2>/dev/null || log_warn "Cannot disable CoW on $dir"
done

log_step "Mounting ESP..."
mount --mkdir "$ESP_PART" "$MOUNT_POINT_ROOT/boot"

log_success "Disk setup completed!"
log_info "Root: $MOUNT_POINT_ROOT, Boot: $MOUNT_POINT_ROOT/boot"
