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
    sudo pacman -S --noconfirm chezmoi
fi

log_step "Applying personal dotfiles..."
chezmoi init --apply https://github.com/WheelsLab/dotfiles-chezmoi.git

log_step "Installing Niri WM..."
if ! check_command niri; then
    if check_command yay; then
        yay -S --noconfirm niri
    elif check_command paru; then
        paru -S --noconfirm niri
    else
        log_error "No AUR helper (yay/paru) found"
        exit 1
    fi
fi

log_step "Installing Dank Material Shell..."
if check_command yay; then
    yay -S --noconfirm quickshell-git dms-shell-git
elif check_command paru; then
    paru -S --noconfirm quickshell-git dms-shell-git
else
    log_error "No AUR helper (yay/paru) found"
    exit 1
fi

log_step "Generating DMS configuration..."
dms setup colors
dms setup layout
dms setup alttab
dms setup binds
dms setup outputs
dms setup cursor

log_step "Enabling DMS autostart..."
systemctl --user add-wants niri.service dms || true

log_step "Installing DMS greeter..."
if check_command yay; then
    yay -S --noconfirm greetd-dms-greeter-git
elif check_command paru; then
    paru -S --noconfirm greetd-dms-greeter-git
else
    log_error "No AUR helper (yay/paru) found"
    exit 1
fi
dms greeter enable
dms greeter sync

log_step "Installing dgop..."
sudo pacman -S --noconfirm dgop

log_success "Niri + DMS setup completed!"
