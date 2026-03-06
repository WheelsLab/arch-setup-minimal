#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/constants.sh"
source "$SCRIPT_DIR/../lib/logging.sh"
source "$SCRIPT_DIR/../lib/utils.sh"

log_section "Configuring Snapper Snapshot System"

log_step "Installing snapper..."
sudo pacman -S --noconfirm snapper

log_step "Cleaning up existing snapshots directory..."
if mountpoint -q /.snapshots 2>/dev/null; then
    sudo umount /.snapshots
    sudo rmdir /.snapshots
fi

log_step "Creating snapper configuration for root..."
config="root"

# Check if config exists
if sudo snapper list-configs | awk '{print $1}' | grep -qx "$config"; then
    log_info "Snapper config exists, cleaning up..."
    
    # Get all snapshot IDs (excluding 0)
    ids=$(sudo snapper -c "$config" list | awk 'NR>2 {print $1}' | grep -v '^0$' || true)
    
    if [[ -z "$ids" ]]; then
        log_info "No snapshots to delete"
    else
        count=$(echo "$ids" | wc -l)
        
        if [[ "$count" -eq 1 ]]; then
            id=$(echo "$ids")
            log_info "Deleting snapshot $id"
            sudo snapper -c "$config" delete --sync "$id"
        else
            last_id=$(echo "$ids" | tail -n1)
            log_info "Deleting snapshots 1-$last_id"
            sudo snapper -c "$config" delete --sync 1-"$last_id"
        fi
    fi
    
    # Unmount /.snapshots
    if mountpoint -q /.snapshots 2>/dev/null; then
        sudo umount /.snapshots
    fi
    
    # Remove config file
    sudo rm -f "/etc/snapper/configs/$config"
    
    # Update snapper config
    if [[ -f /etc/conf.d/snapper ]]; then
        sudo sed -i 's/^SNAPPER_CONFIGS=.*/SNAPPER_CONFIGS=""/' /etc/conf.d/snapper
    fi
    
    log_info "Snapper cleanup complete"
    
    # Delete .snapshots btrfs subvolume
    if sudo btrfs subvolume list / | grep -q '\.snapshots'; then
        log_info "Deleting .snapshots subvolume"
        sudo btrfs subvolume delete /.snapshots 2>/dev/null || true
    fi
fi

sudo snapper -c root create-config /

log_step "Removing snapper auto-created subvolume..."
if sudo btrfs subvolume list / | grep -q '\.snapshots'; then
    sudo btrfs subvolume delete /.snapshots 2>/dev/null || true
fi

log_step "Recreating snapshots directory..."
sudo mkdir -p /.snapshots
sudo mount /.snapshots/

log_step "Installing snap-pac (pacman integration)..."
sudo pacman -S --noconfirm snap-pac

log_step "Installing cronie (automatic timeline snapshots)..."
sudo pacman -S --noconfirm cronie

log_step "Enabling cronie service..."
sudo systemctl enable --now cronie.service

log_success "Snapper snapshot system configured!"
log_info "Snapper configs: snapper list-configs"
log_info "Create manual snapshot: snapper -c root create --description 'manual'"
