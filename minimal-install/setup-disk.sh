#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/constants.sh"
source "$SCRIPT_DIR/../lib/logging.sh"
source "$SCRIPT_DIR/../lib/utils.sh"

check_root
log_section "Disk Partitioning: LUKS + Btrfs"

log_warn "This script will completely wipe the selected disk!"

echo ""
echo "Press Enter to continue to information collection..."
read

echo ""
echo "Available disks:"
lsblk -d -o NAME,SIZE,MODEL,TYPE | grep disk

echo ""
log_success "Select Disk"
prompt "Enter the target disk (e.g., /dev/vda): " DISK

if [[ ! "$DISK" =~ ^/dev/ ]]; then
    DISK="/dev/$DISK"
fi

if [[ ! -b "$DISK" ]]; then
    log_error "Disk $DISK does not exist"
    exit 1
fi

echo ""
echo "Selected disk: $DISK"
echo "Disk info:"
lsblk -o NAME,SIZE,TYPE,PTTYPE,FSTYPE,MOUNTPOINT "$DISK"

echo ""
log_success "System Information"
prompt "Enter hostname [archer]: " HOSTNAME
HOSTNAME="${HOSTNAME:-archer}"

echo ""
prompt "Enter username: " USERNAME
while [[ -z "$USERNAME" ]]; do
    log_error "Username cannot be empty"
    prompt "Enter username: " USERNAME
done

echo ""
prompt "Confirm username '$USERNAME': " CONFIRM
while [[ "$CONFIRM" != "$USERNAME" ]]; do
    log_error "Username does not match"
    prompt "Enter username: " USERNAME
    prompt "Confirm username '$USERNAME': " CONFIRM
done

echo ""
log_success "User Password"
prompt "Enter password for '$USERNAME': " -s
USER_PASS="$REPLY"
echo
prompt "Confirm password: " -s
USER_PASS2="$REPLY"
echo
while [[ "$USER_PASS" != "$USER_PASS2" ]]; do
    log_error "Passwords do not match"
    prompt "Enter password for '$USERNAME': " -s
    USER_PASS="$REPLY"
    echo
    prompt "Confirm password: " -s
    USER_PASS2="$REPLY"
    echo
done

echo ""
log_success "Root Password"
prompt "Enter root password: " -s
ROOT_PASS="$REPLY"
echo
prompt "Confirm root password: " -s
ROOT_PASS2="$REPLY"
echo
while [[ "$ROOT_PASS" != "$ROOT_PASS2" ]]; do
    log_error "Passwords do not match"
    prompt "Enter root password: " -s
    ROOT_PASS="$REPLY"
    echo
    prompt "Confirm root password: " -s
    ROOT_PASS2="$REPLY"
    echo
done

echo ""
log_success "Encryption Password"

while true; do
    prompt "Enter LUKS password: " -s
    LUKS_PASSWORD="$REPLY"
    echo
    prompt "Confirm LUKS password: " -s
    LUKS_PASSWORD2="$REPLY"
    echo
    [[ "$LUKS_PASSWORD" == "$LUKS_PASSWORD2" ]] && break
    log_error "Passwords do not match. Try again."
done

echo ""
echo "============================================"
log_section "Installation Plan"
echo "============================================"
echo ""

DISK_NAME=$(basename "$DISK")
ESP_PART_DISPLAY="${DISK_NAME}1"
SYSTEM_PART_DISPLAY="${DISK_NAME}2"

echo "Disk:        $DISK"
echo "Hostname:    $HOSTNAME"
echo "Username:    $USERNAME"
echo "Root:       (set)"
echo ""
echo "Partition Layout:"
echo "  - ESP:     /dev/${ESP_PART_DISPLAY} (8 GiB, FAT32)"
echo "  - System:  /dev/${SYSTEM_PART_DISPLAY} (LUKS encrypted, Btrfs)"
echo ""
echo "Btrfs Subvolumes:"
echo "  - @            -> /"
echo "  - @home        -> /home"
echo "  - @log         -> /var/log"
echo "  - @pkg         -> /var/cache/pacman/pkg"
echo "  - @snapshots   -> /.snapshots"
echo "  - @games       -> /mnt/games"
echo "  - @vm/@libvirt -> /var/lib/libvirt"
echo "  - @vm/@qemu    -> /var/lib/qemu"
echo "  - @container/@docker  -> /var/lib/docker"
echo "  - @container/@podman  -> /var/lib/containers"
echo ""
echo "Packages to install:"
echo "  base, linux, linux-firmware, intel-ucode,"
echo "  btrfs-progs, networkmanager, openssh,"
echo "  vim, man-db, man-pages, texinfo"
echo ""
echo "============================================"
echo ""

prompt "Confirm to start installation? [y/N]: " -n1
echo
if [[ "$REPLY" != "y" && "$REPLY" != "Y" ]]; then
    log_error "Aborted"
    exit 1
fi

echo ""
log_warn "About to WIPE and REPARTITION $DISK!"
printf "${COLOR_ORANGE}Type 'YES' to confirm: ${COLOR_NC}"
read CONFIRM
if [[ "$CONFIRM" != "YES" ]]; then
    log_error "Aborted"
    exit 1
fi

echo "$DISK" > /tmp/install-disk
echo "$HOSTNAME" > /tmp/install-hostname
echo "$USERNAME" > /tmp/install-username
echo "$USER_PASS" > /tmp/install-user-pass
echo "$ROOT_PASS" > /tmp/install-root-pass
echo "$LUKS_PASSWORD" > /tmp/install-luks-pass

log_section "Configuring"

set_phase "磁盘分区"

log_step "Checking for existing mounts..."
if mountpoint -q /mnt 2>/dev/null; then
    log_warn "Unmounting existing mounts on /mnt..."
    umount -R /mnt 2>/dev/null || true
fi

log_step "Closing any active LUKS containers..."
for mapper in /dev/mapper/crypt*; do
    [[ -e "$mapper" ]] && cryptsetup close "$mapper" 2>/dev/null && log_info "Closed $mapper"
done

log_step "Refreshing partition table..."
partprobe "$DISK" 2>/dev/null || true

ESP_SIZE="8GiB"
CRYPT_NAME="cryptsystem"
MOUNT_ROOT="/mnt"

run_live_summary "Wiping disk" parted -s "$DISK" mklabel gpt

run_live_summary "Creating GPT partitions" \
    parted -s "$DISK" mkpart ESP fat32 1MiB "$ESP_SIZE" \
    parted -s "$DISK" set 1 esp on \
    parted -s "$DISK" mkpart crypt "$ESP_SIZE" 100%

partprobe "$DISK"

ESP_PART="${DISK}p1"
[[ ! -b "${DISK}p1" ]] && ESP_PART="${DISK}1"
SYSTEM_PART="${DISK}p2"
[[ ! -b "${DISK}p2" ]] && SYSTEM_PART="${DISK}2"

log_info "ESP: $ESP_PART, System: $SYSTEM_PART"

run_live_summary "Formatting ESP" mkfs.fat -F32 "$ESP_PART"

run_live_summary "Setting up LUKS" \
    echo -n "$LUKS_PASSWORD" | cryptsetup luksFormat "$SYSTEM_PART" - \
    echo -n "$LUKS_PASSWORD" | cryptsetup open "$SYSTEM_PART" "$CRYPT_NAME" -

run_live_summary "Creating Btrfs filesystem" mkfs.btrfs "/dev/mapper/$CRYPT_NAME"

run_live_summary "Mounting top-level Btrfs" mount "/dev/mapper/$CRYPT_NAME" "$MOUNT_ROOT"

log_step "Creating subvolumes..."
btrfs subvolume create "$MOUNT_ROOT/@"
btrfs subvolume create "$MOUNT_ROOT/@home"
btrfs subvolume create "$MOUNT_ROOT/@log"
btrfs subvolume create "$MOUNT_ROOT/@pkg"
btrfs subvolume create "$MOUNT_ROOT/@snapshots"
btrfs subvolume create "$MOUNT_ROOT/@games"

log_step "Creating nested subvolumes..."
btrfs subvolume create "$MOUNT_ROOT/@vm"
btrfs subvolume create "$MOUNT_ROOT/@vm/@libvirt"
btrfs subvolume create "$MOUNT_ROOT/@vm/@qemu"
btrfs subvolume create "$MOUNT_ROOT/@container"
btrfs subvolume create "$MOUNT_ROOT/@container/@docker"
btrfs subvolume create "$MOUNT_ROOT/@container/@podman"

run_live_summary "Unmounting top-level" umount "$MOUNT_ROOT"

log_step "Mounting subvolumes..."
mount -o subvol=@,compress=zstd,noatime "/dev/mapper/$CRYPT_NAME" "$MOUNT_ROOT"

mkdir -p "$MOUNT_ROOT"/{boot,home,var/log,var/cache/pacman/pkg,.snapshots,mnt/games,var/lib/libvirt,var/lib/qemu,var/lib/docker,var/lib/containers}

mount -o subvol=@home,compress=zstd,noatime "/dev/mapper/$CRYPT_NAME" "$MOUNT_ROOT/home"
mount -o subvol=@log,compress=zstd,noatime "/dev/mapper/$CRYPT_NAME" "$MOUNT_ROOT/var/log"
mount -o subvol=@pkg,compress=zstd,noatime "/dev/mapper/$CRYPT_NAME" "$MOUNT_ROOT/var/cache/pacman/pkg"
mount -o subvol=@snapshots,compress=zstd,noatime "/dev/mapper/$CRYPT_NAME" "$MOUNT_ROOT/.snapshots"
mount -o subvol=@games,compress=zstd,noatime "/dev/mapper/$CRYPT_NAME" "$MOUNT_ROOT/mnt/games"

mount -o subvol=@vm/@libvirt,compress=zstd,noatime "/dev/mapper/$CRYPT_NAME" "$MOUNT_ROOT/var/lib/libvirt"
mount -o subvol=@vm/@qemu,compress=zstd,noatime "/dev/mapper/$CRYPT_NAME" "$MOUNT_ROOT/var/lib/qemu"
mount -o subvol=@container/@docker,compress=zstd,noatime "/dev/mapper/$CRYPT_NAME" "$MOUNT_ROOT/var/lib/docker"
mount -o subvol=@container/@podman,compress=zstd,noatime "/dev/mapper/$CRYPT_NAME" "$MOUNT_ROOT/var/lib/containers"

log_step "Disabling CoW on high I/O subvolumes..."
for dir in "$MOUNT_ROOT/mnt/games" \
           "$MOUNT_ROOT/var/lib/libvirt" "$MOUNT_ROOT/var/lib/qemu" \
           "$MOUNT_ROOT/var/lib/docker" "$MOUNT_ROOT/var/lib/containers"; do
    chattr +C "$dir" 2>/dev/null || log_warn "Cannot disable CoW on $dir"
done

run_live_summary "Mounting ESP" mount "$ESP_PART" "$MOUNT_ROOT/boot"

log_success "Disk setup completed!"
log_info "Root: $MOUNT_ROOT, Boot: $MOUNT_ROOT/boot"
log_info "LUKS container: $CRYPT_NAME"

LUKS_UUID=$(blkid -s UUID -o value "$SYSTEM_PART")
log_info "LUKS UUID: $LUKS_UUID"

finish_phase
