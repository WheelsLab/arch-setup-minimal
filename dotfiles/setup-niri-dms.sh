#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/constants.sh"
source "$SCRIPT_DIR/../lib/logging.sh"
source "$SCRIPT_DIR/../lib/utils.sh"

trap 'log_error "Script failed at line $LINENO: $BASH_COMMAND" && exit 1' ERR

log_section "Installing Niri + DMS"

log_step "Installing chezmoi..."
if ! check_command chezmoi; then
    retry_command 3 sudo pacman -S --noconfirm chezmoi || {
        log_error "Failed to install chezmoi"
        exit 1
    }
fi

log_step "Applying personal dotfiles..."
retry_command 3 chezmoi init --apply https://github.com/WheelsLab/dotfiles-chezmoi.git

log_step "Installing Niri WM..."
if ! check_command niri; then
    if check_command yay; then
        retry_command 3 yay -S --noconfirm niri
    elif check_command paru; then
        retry_command 3 paru -S --noconfirm niri
    else
        log_error "No AUR helper (yay/paru) found"
        exit 1
    fi
fi

log_step "Installing Dank Material Shell..."
if check_command yay; then
    retry_command 3 yay -S --noconfirm quickshell-git dms-shell-git
elif check_command paru; then
    retry_command 3 paru -S --noconfirm quickshell-git dms-shell-git
else
    log_error "No AUR helper (yay/paru) found"
    exit 1
fi

log_step "Generating DMS configuration..."
if check_command dms; then
    dms setup colors
    dms setup layout
    dms setup alttab
    dms setup binds
    dms setup outputs
    dms setup cursor
else
    log_warn "dms command not found, skipping DMS configuration"
fi

log_step "Enabling DMS autostart..."
systemctl --user add-wants niri.service dms || true

log_step "Installing DMS greeter..."
if check_command yay; then
    retry_command 3 yay -S --noconfirm greetd-dms-greeter-git
elif check_command paru; then
    retry_command 3 paru -S --noconfirm greetd-dms-greeter-git
else
    log_error "No AUR helper (yay/paru) found"
    exit 1
fi

if check_command dms; then
    dms greeter enable
    dms greeter sync
fi

log_step "Installing dgop..."
retry_command 3 sudo pacman -S --noconfirm dgop || {
    log_error "Failed to install dgop"
    exit 1
}

log_success "Niri + DMS setup completed!"
