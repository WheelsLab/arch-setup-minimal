#!/usr/bin/env bash

# Constants for Arch Linux minimal setup

# Disk configuration
readonly DEFAULT_ROOT_SIZE="40G"
readonly DEFAULT_SWAP_SIZE="8G"
readonly DEFAULT_BOOT_SIZE="1G"

# Encryption
readonly LUKS_CONTAINER_NAME="cryptroot"
readonly LUKS_CONTAINER_NAME_BOOT="cryptboot"

# Btrfs subvolumes
readonly BTRFS_SUBVOL_ROOT="@"
readonly BTRFS_SUBVOL_HOME="@home"
readonly BTRFS_SUBVOL_LOG="@log"
readonly BTRFS_SUBVOL_CACHE="@cache"
readonly BTRFS_SUBVOL_SNAPSHOTS="@snapshots"

# Mount points
readonly MOUNT_POINT_ROOT="/mnt"
readonly MOUNT_POINT_BOOT="/mnt/boot"
readonly MOUNT_POINT_BOOT_EFI="/mnt/boot/efi"

# Package groups
readonly BASE_PACKAGES="base base-devel linux linux-firmware"
readonly ESSENTIAL_PACKAGES="vim git wget curl reflector"
readonly AUR_HELPER="paru"

# Network packages
readonly NETWORK_PACKAGES="iwd dhcpcd networkmanager"

# Locale
readonly DEFAULT_LOCALE="en_US.UTF-8"
readonly DEFAULT_TIMEZONE="UTC"

# Colors for output
readonly COLOR_RED="\033[0;31m"
readonly COLOR_GREEN="\033[0;32m"
readonly COLOR_YELLOW="\033[0;33m"
readonly COLOR_BLUE="\033[0;34m"
readonly COLOR_ORANGE="\033[0;33m"
readonly COLOR_NC="\033[0m"
