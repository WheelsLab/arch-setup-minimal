#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/constants.sh"
source "$SCRIPT_DIR/../lib/logging.sh"
source "$SCRIPT_DIR/../lib/utils.sh"

log_section "Configuring Snapper Snapshot System"

SNAPSHOTS_SUBVOL="@snapshots"

log_step "Installing snapper..."
retry_command 3 sudo pacman -S --noconfirm snapper

log_step "Detecting snapshots subvolume..."
if sudo btrfs subvolume list / | grep -q "@snapshots"; then
    SNAPSHOTS_SUBVOL="@snapshots"
    log_info "Using @snapshots subvolume"
elif sudo btrfs subvolume list / | grep -q "\.snapshots"; then
    SNAPSHOTS_SUBVOL=".snapshots"
    log_info "Using .snapshots subvolume"
else
    log_warn "No snapshots subvolume found, will create one"
    SNAPSHOTS_SUBVOL="@snapshots"
fi

SNAPSHOT_ROOT="/$SNAPSHOTS_SUBVOL"

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
    
    sudo rm -f "/etc/snapper/configs/$config" || true
    
    if [[ -f /etc/conf.d/snapper ]]; then
        sudo sed -i 's/^SNAPPER_CONFIGS=.*/SNAPPER_CONFIGS=""/' /etc/conf.d/snapper || true
    fi
    
    log_info "Snapper cleanup complete"
fi

log_step "Unmounting snapshots if mounted..."
if mountpoint -q "$SNAPSHOT_ROOT" 2>/dev/null; then
    sudo umount "$SNAPSHOT_ROOT" || true
fi

log_step "Creating snapper configuration for root..."
sudo snapper -c root create-config / || {
    log_error "Failed to create snapper config"
    exit 1
}

log_step "Cleaning up snapper auto-created subvolume..."
if sudo btrfs subvolume list / | grep -q "$SNAPSHOTS_SUBVOL"; then
    if ! mountpoint -q "$SNAPSHOT_ROOT" 2>/dev/null; then
        sudo mkdir -p "$SNAPSHOT_ROOT"
        sudo mount "$SNAPSHOT_ROOT"
    fi
    
    if mountpoint -q "$SNAPSHOT_ROOT" 2>/dev/null; then
        sudo btrfs subvolume delete "$SNAPSHOT_ROOT"/* 2>/dev/null || true
    fi
fi

log_step "Recreating snapshots directory..."
sudo mkdir -p "$SNAPSHOT_ROOT"
sudo mount "$SNAPSHOT_ROOT"

log_step "Installing snap-pac (pacman integration)..."
retry_command 3 sudo pacman -S --noconfirm snap-pac

log_step "Installing cronie (automatic timeline snapshots)..."
retry_command 3 sudo pacman -S --noconfirm cronie

log_step "Enabling cronie service..."
sudo systemctl enable --now cronie.service

log_success "Snapper snapshot system configured!"
log_info "Snapper configs: snapper list-configs"
log_info "Create manual snapshot: snapper -c root create --description 'manual'"
