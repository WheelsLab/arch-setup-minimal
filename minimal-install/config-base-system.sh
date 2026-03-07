#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/constants.sh"
source "$SCRIPT_DIR/../lib/logging.sh"
source "$SCRIPT_DIR/../lib/utils.sh"

check_root
log_section "Configuring Base System"

MOUNT_ROOT="/mnt"

if [[ -f /tmp/install-hostname ]]; then
    HOSTNAME=$(cat /tmp/install-hostname)
else
    prompt "Enter hostname [archer]: " HOSTNAME
    HOSTNAME="${HOSTNAME:-archer}"
fi

if [[ -f /tmp/install-username ]]; then
    USERNAME=$(cat /tmp/install-username)
else
    prompt "Enter username: " USERNAME
    while [[ -z "$USERNAME" ]]; do
        log_error "Username cannot be empty"
        prompt "Enter username: " USERNAME
    done
fi

if [[ -f /tmp/install-user-pass ]]; then
    USER_PASS=$(cat /tmp/install-user-pass)
else
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
fi

log_step "Setting timezone..."
arch-chroot "$MOUNT_ROOT" ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

log_step "Synchronizing hardware clock..."
arch-chroot "$MOUNT_ROOT" hwclock --systohc

log_step "Configuring locale..."
sed -i '/^#en_US.UTF-8 UTF-8/s/^#//' "$MOUNT_ROOT/etc/locale.gen"
sed -i '/^#zh_CN.UTF-8 UTF-8/s/^#//' "$MOUNT_ROOT/etc/locale.gen"
arch-chroot "$MOUNT_ROOT" locale-gen

log_step "Setting locale.conf..."
echo "LANG=en_US.UTF-8" > "$MOUNT_ROOT/etc/locale.conf"

log_step "Setting hostname..."
echo "$HOSTNAME" > "$MOUNT_ROOT/etc/hostname"

log_step "Enabling NetworkManager..."
arch-chroot "$MOUNT_ROOT" systemctl enable NetworkManager.service

log_step "Setting root password..."
if [[ -f /tmp/install-root-pass ]]; then
    ROOT_PASS=$(cat /tmp/install-root-pass)
    echo "root:$ROOT_PASS" | arch-chroot "$MOUNT_ROOT" chpasswd
else
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
    echo "root:$ROOT_PASS" | arch-chroot "$MOUNT_ROOT" chpasswd
fi

log_step "Creating admin user..."
if ! arch-chroot "$MOUNT_ROOT" id "$USERNAME" 2>/dev/null; then
    arch-chroot "$MOUNT_ROOT" useradd -m -G wheel -s /bin/bash "$USERNAME"
    log_info "User '$USERNAME' created"
else
    log_info "User '$USERNAME' already exists"
fi

log_step "Installing sudo..."
arch-chroot "$MOUNT_ROOT" pacman -S --noconfirm sudo || {
    log_error "Failed to install sudo"
    exit 1
}

log_step "Configuring sudo for wheel group..."
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' "$MOUNT_ROOT/etc/sudoers"

log_step "Setting user password..."
echo "$USERNAME:$USER_PASS" | arch-chroot "$MOUNT_ROOT" chpasswd

set_phase "配置系统"

log_step "Setting up archlinuxcn repository..."
if ! grep -q '\[archlinuxcn\]' /etc/pacman.conf; then
cat >> "$MOUNT_ROOT/etc/pacman.conf" <<'EOF'

[archlinuxcn]
Server = https://repo.archlinuxcn.org/$arch
EOF
fi

run_live_summary "Installing archlinuxcn-keyring" \
    arch-chroot "$MOUNT_ROOT" pacman -Sy --noconfirm archlinuxcn-keyring

run_live_summary "Installing archlinuxcn-mirrorlist-git" \
    arch-chroot "$MOUNT_ROOT" pacman -Su --noconfirm archlinuxcn-mirrorlist-git

log_step "Updating pacman.conf with mirrorlist..."
sed -i '/\[archlinuxcn\]/a Include = /etc/pacman.d/archlinuxcn-mirrorlist' "$MOUNT_ROOT/etc/pacman.conf"

log_success "Base system configured!"

finish_phase
