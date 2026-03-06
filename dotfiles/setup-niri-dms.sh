#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/constants.sh"
source "$SCRIPT_DIR/../lib/logging.sh"
source "$SCRIPT_DIR/../lib/utils.sh"

trap 'log_error "Script failed at line $LINENO: $BASH_COMMAND" && exit 1' ERR

install_aur() {
    local package="$1"
    if check_command yay; then
        retry_command 3 yay -S --noconfirm "$package"
    elif check_command paru; then
        retry_command 3 paru -S --noconfirm "$package"
    else
        log_error "No AUR helper (yay/paru) found"
        exit 1
    fi
}

log_section "Installing Niri + DMS"

log_step "Installing chezmoi..."
if ! check_command chezmoi; then
    sudo pacman -S --noconfirm chezmoi || {
        log_error "Failed to install chezmoi"
        exit 1
    }
fi

log_step "Applying personal dotfiles..."
retry_command 3 chezmoi init --apply https://github.com/WheelsLab/dotfiles-chezmoi.git

log_step "Installing Niri WM..."
if ! check_command niri; then
    install_aur niri
fi

log_step "Installing Dank Material Shell..."
install_aur quickshell-git dms-shell-git

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
install_aur greetd-dms-greeter-git
dms greeter enable
dms greeter sync

log_step "Installing dgop..."
sudo pacman -S --noconfirm dgop || {
    log_error "Failed to install dgop"
    exit 1
}

log_success "Niri + DMS setup completed!"
