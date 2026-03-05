#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/constants.sh"
source "$SCRIPT_DIR/lib/logging.sh"
source "$SCRIPT_DIR/lib/utils.sh"

show_usage() {
    cat <<EOF
Arch Linux Minimal Setup

Usage: $0 [COMMAND]

Commands:
    minimal          Run minimal install phase
    post             Run post-install phase
    dotfiles         Setup dotfiles
    all              Run all phases in order
    help             Show this help message

Without command, shows interactive menu.

EOF
}

show_menu() {
    echo -e "${COLOR_BLUE}
=======================================
  Arch Linux Minimal Setup
=======================================

  1) Minimal Install (base system)
  2) Post-Install (packages & config)
  3) Dotfiles (DMS & Niri)
  4) Run All
  5) Help
  0) Exit

=======================================
${COLOR_NC}"
}

run_minimal() {
    log_section "Starting Minimal Install Phase"
    
    local scripts=(
        "minimal-install/setup-disk.sh"
        "minimal-install/setup-base-pkg.sh"
        "minimal-install/config-base-system.sh"
        "minimal-install/setup-bootloader.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [[ -f "$SCRIPT_DIR/$script" ]]; then
            log_step "Running: $script"
            bash "$SCRIPT_DIR/$script" || {
                log_error "Failed: $script"
                exit 1
            }
        else
            log_warn "Script not found: $script"
        fi
    done
    
    log_info "Minimal install completed!"
    log_info "Now you can reboot: umount -R /mnt && reboot"
}

run_post() {
    log_section "Starting Post-Install Phase"
    
    local scripts=(
        "post-install/01-system-packages.sh"
        "post-install/02-desktop-env.sh"
        "post-install/03-snapper.sh"
        "post-install/04-automate-boot.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [[ -f "$SCRIPT_DIR/$script" ]]; then
            log_step "Running: $script"
            bash "$SCRIPT_DIR/$script" || {
                log_error "Failed: $script"
                exit 1
            }
        else
            log_warn "Script not found: $script"
        fi
    done
    
    log_success "Post-install completed!"
}

run_dotfiles() {
    log_section "Setting Up Dotfiles"
    
    if [[ -f "$SCRIPT_DIR/dotfiles/setup.sh" ]]; then
        bash "$SCRIPT_DIR/dotfiles/setup.sh"
    else
        log_error "dotfiles/setup.sh not found"
        exit 1
    fi
    
    log_success "Dotfiles setup completed!"
}

run_all() {
    run_minimal
    run_post
    run_dotfiles
    log_section "All phases completed!"
}

interactive_menu() {
    while true; do
        show_menu
        read -p "Select option: " choice
        
        case "$choice" in
            1) run_minimal ;;
            2) run_post ;;
            3) run_dotfiles ;;
            4) run_all ;;
            5) show_usage ;;
            0) exit 0 ;;
            *) log_error "Invalid option" ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

main() {
    init_log "/tmp/arch-setup.log"
    
    if [[ $# -eq 0 ]]; then
        interactive_menu
    else
        case "$1" in
            minimal) run_minimal ;;
            post) run_post ;;
            dotfiles) run_dotfiles ;;
            all) run_all ;;
            help|--help|-h) show_usage ;;
            *) log_error "Unknown command: $1"; show_usage; exit 1 ;;
        esac
    fi
}

main "$@"
