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

    local packages=()

    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        # 去掉行尾注释
        line="${line%%#*}"
        line="${line%"${line##*[![:space:]]}"}"

        [[ -n "$line" ]] && packages+=("$line")
    done < "$pkglist_file"

    if [[ ${#packages[@]} -gt 0 ]]; then
        log_step "Installing packages from $(basename "$pkglist_file")..."
        retry_command 3 "$aur_helper" -S --noconfirm --needed "${packages[@]}"
    fi
}

log_step "Installing terminal tools..."
install_from_pkglist "$SCRIPT_DIR/../pkglist/terminal-tools.txt"

if confirm "Install desktop app?" y; then
    log_step "Installing desktop applications..."
    install_from_pkglist "$SCRIPT_DIR/../pkglist/desktop.txt"
fi

if confirm "Install embedded dev tools?" y; then
    log_step "Installing development and embedded tools..."
    install_from_pkglist "$SCRIPT_DIR/../pkglist/dev-embedded.txt"
fi

log_success "Application installation completed!"