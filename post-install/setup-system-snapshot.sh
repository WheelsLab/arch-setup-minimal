#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/constants.sh"
source "$SCRIPT_DIR/../lib/logging.sh"
source "$SCRIPT_DIR/../lib/utils.sh"

log_section "Configuring Snapper Snapshot System"

log_step "Installing snapper..."
retry_command 3 sudo pacman -S --noconfirm snapper

log_step "Cleaning up existing snapper configuration..."
config="root"

if sudo snapper list-configs | awk '{print $1}' | grep -qx "$config"; then
    log_info "Snapper config exists, cleaning up..."
    
    ids=$(sudo snapper -c "$config" list | awk 'NR>2 {print $1}' | grep -v '^0$' || true)
    
    if [[ -n "$ids" ]]; then
        count=$(echo "$ids" | wc -l)
        log_info "Deleting $count snapshots..."
        last_id=$(echo "$ids" | tail -n1)
        sudo snapper -c "$config" delete --sync 1-"$last_id" || true
    fi
    
    log_info "Removing snapper config file..."
    sudo rm -f "/etc/snapper/configs/$config"
    
    if [[ -f /etc/conf.d/snapper ]]; then
        log_info "Clearing SNAPPER_CONFIGS in /etc/conf.d/snapper..."
        sudo sed -i 's/^SNAPPER_CONFIGS=.*/SNAPPER_CONFIGS=""/' /etc/conf.d/snapper
    fi
    
    log_info "Snapper cleanup complete"
fi

log_step "Unmounting /.snapshots if mounted..."
if mountpoint -q /.snapshots 2>/dev/null; then
    sudo umount /.snapshots
fi

log_step "Creating snapper configuration for root..."
sudo snapper -c root create-config / || {
    log_error "Failed to create snapper config"
    exit 1
}

log_step "Cleaning up snapper auto-created subvolume..."
if sudo btrfs subvolume list / | grep -q '\.snapshots'; then
    sudo btrfs subvolume delete /.snapshots 2>/dev/null || true
fi

log_step "Recreating /.snapshots directory..."
sudo mkdir -p /.snapshots

log_step "Adding /.snapshots to /etc/fstab if not exists..."
if ! grep -q '/.snapshots' /etc/fstab; then
    ROOT_UUID=$(grep ' / btrfs ' /etc/fstab | awk '{print $1}' | cut -d'=' -f2)
    if [[ -n "$ROOT_UUID" ]]; then
        echo "UUID=$ROOT_UUID  /.snapshots  btrfs  subvol=@snapshots,compress=zstd,ssd,noatime  0 0" | sudo tee -a /etc/fstab > /dev/null
        log_info "Added /.snapshots to /etc/fstab with UUID=$ROOT_UUID"
    else
        log_error "Failed to get root UUID from /etc/fstab"
        exit 1
    fi
fi

log_step "Mounting /.snapshots..."
sudo mount /.snapshots/

log_step "Installing snap-pac (pacman integration)..."
retry_command 3 sudo pacman -S --noconfirm snap-pac

log_step "Installing cronie (automatic timeline snapshots)..."
retry_command 3 sudo pacman -S --noconfirm cronie

log_step "Enabling cronie service..."
sudo systemctl enable --now cronie.service

log_success "Snapper snapshot system configured!"
log_info "Snapper configs: snapper list-configs"
log_info "Create manual snapshot: snapper -c root create --description 'manual'"
