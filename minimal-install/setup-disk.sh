#!/bin/bash
# LiveCD 自动化分区 + LUKS + Btrfs + 嵌套子卷脚本（用户交互版，显示磁盘列表）
set -euo pipefail

RED='\033[0;31m'
NC='\033[0m'
MOUNT_POINT="/mnt"

echo -e "${RED}WARNING: This script will completely wipe the selected disk!${NC}"

# ===== 1. 打印系统磁盘 =====
echo -e "${RED}Available disks:${NC}"
lsblk -d -o NAME,SIZE,MODEL,TYPE | grep disk

# ===== 2. 用户输入磁盘 =====
read -rp "Enter the full path of the target disk to operate on (e.g., /dev/vda): " DISK

# ===== 3. 检查磁盘是否存在 =====
if [ ! -b "$DISK" ]; then
    echo -e "${RED}Error: Disk $DISK does not exist.${NC}"
    exit 1
fi

# ===== 4. 显示现有分区 =====
echo -e "${RED}Current partitions on $DISK:${NC}"
lsblk "$DISK"

# ===== 5. 用户确认 =====
echo -e "${RED}About to wipe and repartition $DISK!${NC}"
read -rp "Type 'YES' to confirm: " CONFIRM
if [ "$CONFIRM" != "YES" ]; then
    echo "Aborted by user."
    exit 0
fi

# ===== 6. 用户输入 LUKS 密码 =====
read -rsp "Enter password for LUKS encryption: " PASSWORD
echo

# ===== 7. 配置 =====
ESP_SIZE="512M"
CRYPT_NAME="cryptsystem"
BTRFS_LABEL="archsystem"

# 高 I/O 子卷
IO_SUBVOLS=(
  "$MOUNT_POINT/var/lib/libvirt"
  "$MOUNT_POINT/var/lib/qemu"
  "$MOUNT_POINT/var/lib/docker"
  "$MOUNT_POINT/var/lib/containers"
  "$MOUNT_POINT/mnt/games"
)

# ===== 8. 清空磁盘 =====
echo -e "${RED}Wiping disk $DISK ...${NC}"
sgdisk --zap-all "$DISK"
wipefs -a "$DISK"

# ===== 9. 创建分区 =====
echo -e "${RED}Creating GPT partitions ...${NC}"
sgdisk -n1:0:+$ESP_SIZE -t1:EF00 "$DISK"  # ESP
sgdisk -n2:0:0 -t2:8300 "$DISK"           # SYSTEM
partprobe "$DISK"

ESP_PART=$(lsblk -ln -o NAME "$DISK" | awk 'NR==2 {print "/dev/" $1}')
SYSTEM_PART=$(lsblk -ln -o NAME "$DISK" | awk 'NR==3 {print "/dev/" $1}')
echo -e "${RED}ESP: $ESP_PART, SYSTEM: $SYSTEM_PART${NC}"

# ===== 10. 格式化 ESP =====
echo -e "${RED}Formatting ESP ...${NC}"
mkfs.fat -F32 "$ESP_PART"

# ===== 11. 设置 LUKS =====
echo -e "${RED}Setting up LUKS on SYSTEM ...${NC}"
echo -n "$PASSWORD" | cryptsetup luksFormat "$SYSTEM_PART" -
echo -n "$PASSWORD" | cryptsetup open "$SYSTEM_PART" "$CRYPT_NAME" -

# ===== 12. 创建 Btrfs 文件系统 =====
echo -e "${RED}Creating Btrfs on SYSTEM ...${NC}"
mkfs.btrfs -L "$BTRFS_LABEL" /dev/mapper/$CRYPT_NAME

# ===== 13. 挂载顶层卷 =====
echo -e "${RED}Mounting SYSTEM top-level ...${NC}"
mkdir -p "$MOUNT_POINT"
mount /dev/mapper/$CRYPT_NAME "$MOUNT_POINT"

# ===== 14. 创建子卷 =====
echo -e "${RED}Creating top-level subvolumes ...${NC}"
btrfs subvolume create "$MOUNT_POINT/@"
btrfs subvolume create "$MOUNT_POINT/@home"
btrfs subvolume create "$MOUNT_POINT/@snapshots"
btrfs subvolume create "$MOUNT_POINT/@pkg"
btrfs subvolume create "$MOUNT_POINT/@log"
btrfs subvolume create "$MOUNT_POINT/@games"

echo -e "${RED}Creating intermediate and nested subvolumes ...${NC}"
# @vm
btrfs subvolume create "$MOUNT_POINT/@vm"
btrfs subvolume create "$MOUNT_POINT/@vm/@libvirt"
btrfs subvolume create "$MOUNT_POINT/@vm/@qemu"
# @container
btrfs subvolume create "$MOUNT_POINT/@container"
btrfs subvolume create "$MOUNT_POINT/@container/@docker"
btrfs subvolume create "$MOUNT_POINT/@container/@podman"

# ===== 15. 卸载顶层卷 =====
umount "$MOUNT_POINT"

# ===== 16. 挂载最终子卷 =====
echo -e "${RED}Mounting final-level subvolumes ...${NC}"
mount -o subvol=@ --mkdir /dev/mapper/$CRYPT_NAME "$MOUNT_POINT"
mount -o subvol=@home --mkdir /dev/mapper/$CRYPT_NAME "$MOUNT_POINT/home"
mount -o subvol=@snapshots --mkdir /dev/mapper/$CRYPT_NAME "$MOUNT_POINT/.snapshots"
mount -o subvol=@pkg --mkdir /dev/mapper/$CRYPT_NAME "$MOUNT_POINT/var/cache/pacman/pkg"
mount -o subvol=@log --mkdir /dev/mapper/$CRYPT_NAME "$MOUNT_POINT/var/log"
mount -o subvol=@vm/@libvirt --mkdir /dev/mapper/$CRYPT_NAME "$MOUNT_POINT/var/lib/libvirt"
mount -o subvol=@vm/@qemu --mkdir /dev/mapper/$CRYPT_NAME "$MOUNT_POINT/var/lib/qemu"
mount -o subvol=@container/@docker --mkdir /dev/mapper/$CRYPT_NAME "$MOUNT_POINT/var/lib/docker"
mount -o subvol=@container/@podman --mkdir /dev/mapper/$CRYPT_NAME "$MOUNT_POINT/var/lib/containers"
mount -o subvol=@games --mkdir /dev/mapper/$CRYPT_NAME "$MOUNT_POINT/mnt/games"

# ===== 17. 高 I/O 子卷关闭 CoW =====
echo -e "${RED}Disabling CoW on high I/O subvolumes ...${NC}"
for dir in "${IO_SUBVOLS[@]}"; do
  chattr +C "$dir" || echo -e "${RED}  Warning: Cannot disable CoW on $dir${NC}"
done

# ===== 18. 挂载 ESP =====
echo -e "${RED}Mounting ESP ...${NC}"
mkdir -p "$MOUNT_POINT/boot"
mount "$ESP_PART" "$MOUNT_POINT/boot"

echo -e "${RED}Nested Btrfs subvolumes created and mounted successfully!${NC}"