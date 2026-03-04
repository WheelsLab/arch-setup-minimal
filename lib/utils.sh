#!/usr/bin/env bash

# Utility functions for Arch Linux minimal setup

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

check_command() {
    command -v "$1" >/dev/null 2>&1
}

check_package() {
    pacman -Qq "$1" >/dev/null 2>&1
}

require_command() {
    local cmd="$1"
    local package="${2:-$cmd}"
    
    if ! check_command "$cmd"; then
        log_error "Command '$cmd' not found. Install '$package' first."
        exit 1
    fi
}

require_package() {
    local pkg="$1"
    if ! check_package "$pkg"; then
        log_info "Installing missing package: $pkg"
        pacman -S --noconfirm "$pkg"
    fi
}

get_device_size() {
    local device="$1"
    blockdev --getsize64 "$device" 2>/dev/null | numfmt --to=iec-i 1024
}

format_size() {
    echo "$1" | numfmt --to=iec-i 1024
}

wait_for_device() {
    local device="$1"
    local timeout="${2:-30}"
    local elapsed=0
    
    while [[ ! -b "$device" ]] && [[ $elapsed -lt $timeout ]]; do
        sleep 1
        ((elapsed++))
    done
    
    [[ -b "$device" ]]
}

is_mounted() {
    mountpoint -q "$1"
}

umount_recursive() {
    local mountpoint="$1"
    
    if is_mounted "$mountpoint"; then
        umount -R "$mountpoint" 2>/dev/null || umount "$mountpoint" 2>/dev/null
    fi
}

close_luks() {
    local device="$1"
    
    if cryptsetup isActive "$device" 2>/dev/null; then
        cryptsetup close "$device"
    fi
}

enable_service() {
    local service="$1"
    if check_command systemctl; then
        systemctl enable "$service" 2>/dev/null
    fi
}

start_service() {
    local service="$1"
    if check_command systemctl; then
        systemctl start "$service" 2>/dev/null
    fi
}

create_btrfs_subvol() {
    local mountpoint="$1"
    local name="$2"
    
    btrfs subvolume create "$mountpoint/$name"
}

set_btrfs_compression() {
    local mountpoint="$1"
    
    btrfs property set "$mountpoint" compression zstd
}

add_btrfs_fstab() {
    local subvol="$1"
    local mountpoint="$2"
    local fstab="/etc/fstab"
    
    echo "UUID=$BTRFS_UUID  $mountpoint  btrfs  subvol=$subvol,compress=zstd,ssd,noatime  0 0" >> "$fstab"
}

get_uuid() {
    blkid -s UUID -o value "$1"
}

is_uefi() {
    [[ -d /sys/firmware/efi ]]
}

is_virtual() {
    if [[ -f /sys/class/dmi/id/product_name ]]; then
        local product
        product=$(cat /sys/class/dmi/id/product_name)
        [[ "$product" == "VMware Virtual Platform" ]] || \
        [[ "$product" == "VirtualBox" ]] || \
        [[ "$product" == "KVM" ]] || \
        [[ "$product" == "Microsoft Corporation" ]]
    else
        return 1
    fi
}

run_in_chroot() {
    local script="$1"
    arch-chroot /mnt bash -c "$(cat "$script")"
}

backup_file() {
    local file="$1"
    local backup="${file}.bak.$(date +%Y%m%d%H%M%S)"
    
    if [[ -f "$file" ]]; then
        cp -a "$file" "$backup"
        log_info "Backed up $file to $backup"
    fi
}

create_directories() {
    local dir
    for dir in "$@"; do
        mkdir -p "$dir"
    done
}
