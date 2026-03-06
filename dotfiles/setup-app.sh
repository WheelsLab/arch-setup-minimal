#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/constants.sh"
source "$SCRIPT_DIR/../lib/logging.sh"
source "$SCRIPT_DIR/../lib/utils.sh"

trap 'log_error "Script failed at line $LINENO: $BASH_COMMAND" && exit 1' ERR

log_section "Installing Desktop Applications"

install_from_pkglist() {
    local pkglist_file="$1"
    local aur_helper=""
    
    if check_command yay; then
        aur_helper="yay"
    elif check_command paru; then
        aur_helper="paru"
    else
        log_error "No AUR helper (yay/paru) found"
        exit 1
    fi
    
    if [[ ! -f "$pkglist_file" ]]; then
        log_warn "pkglist file not found: $pkglist_file"
        return
    fi
    
    local official_packages=()
    local aur_packages=()
    
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        
        if [[ "$line" =~ \#\ AUR$ ]]; then
            local pkg="${line%%\# AUR}"
            pkg="${pkg%"${pkg##*[![:space:]]}"}"
            [[ -n "$pkg" ]] && aur_packages+=("$pkg")
        else
            official_packages+=("$line")
        fi
    done < "$pkglist_file"
    
    if [[ ${#official_packages[@]} -gt 0 ]]; then
        log_step "Installing official packages from $(basename "$pkglist_file")..."
        retry_command 3 sudo pacman -S --noconfirm "${official_packages[@]}"
    fi
    
    if [[ ${#aur_packages[@]} -gt 0 ]]; then
        log_step "Installing AUR packages from $(basename "$pkglist_file")..."
        retry_command 3 "$aur_helper" -S --noconfirm "${aur_packages[@]}"
    fi
}

log_step "Installing desktop applications..."
install_from_pkglist "$SCRIPT_DIR/../pkglist/desktop.txt"

log_step "Installing development and embedded tools..."
install_from_pkglist "$SCRIPT_DIR/../pkglist/dev-embedded.txt"

log_success "Application installation completed!"
