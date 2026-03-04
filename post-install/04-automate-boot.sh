#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/constants.sh"
source "$SCRIPT_DIR/lib/logging.sh"
source "$SCRIPT_DIR/lib/utils.sh"

log_section "Automating Bootloader with Snapper"

BOOT_DIR="/boot"
SNAPPER_HOOK="$BOOT_DIR/snapper-hooks.sh"

log_step "Creating snapper hooks script..."
cat > "$SNAPPER_HOOK" <<'EOF'
#!/bin/bash
# Snapper hook for boot snapshots

SNAPSHOT_NUM=$(snapper -c root create --description "boot snapshot" --read-only 2>/dev/null | grep -oP '\d+$')
if [[ -n "$SNAPSHOT_NUM" ]]; then
    echo "Created boot snapshot: $SNAPSHOT_NUM"
fi
EOF
chmod +x "$SNAPSHOT_HOOK"

log_step "Adding mkinitcpio hook..."
if ! grep -q "snapper" /etc/mkinitcpio.conf 2>/dev/null; then
    sudo sed -i 's/HOOKS=(base udev autodetect/HOOKS=(base udev autodetect snapper/' /etc/mkinitcpio.conf
    sudo mkinitcpio -P
fi

log_step "Configuring Limine for snapshot boot..."
if [[ -f "$BOOT_DIR/limine.cfg" ]]; then
    sudo cat >> "$BOOT_DIR/limine.cfg" <<'EOF'

:Arch Linux (Snapshot)
    PROTOCOL=limine
    KERNEL_PATH=boot:///vmlinuz-linux
    INITRD_PATH=boot:///intel-ucode.img
    CMDLINE=quiet loglevel=3
    MODULE_PATH=boot:///initramfs-linux.img
EOF
fi

log_step "Setting up automatic cleanup..."
sudo systemctl enable fstrim.timer

log_success "Boot automation configured!"
log_info "You can boot into snapshots via Limine bootloader menu"
