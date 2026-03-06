#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/constants.sh"
source "$SCRIPT_DIR/../lib/logging.sh"
source "$SCRIPT_DIR/../lib/utils.sh"

log_section "Installing AUR Helper (paru)"

log_step "Installing base-devel..."
sudo pacman -S --needed base-devel

log_step "Checking if paru is already installed..."
if command -v paru &>/dev/null; then
    log_info "paru is already installed"
else
    log_step "Installing paru from archlinuxcn..."
    if pacman -Qs '^paru$' &>/dev/null; then
        log_info "paru is already in local database"
    else
        sudo pacman -S --noconfirm paru
    fi
fi

log_success "paru installation completed!"
