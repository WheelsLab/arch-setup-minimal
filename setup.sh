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
    clean            Unmount /mnt and close LUKS container
    help             Show this help message

Without command, shows interactive menu.

EOF
}

cleanup() {
    log_section "Cleaning Up"
    
    log_step "Unmounting /mnt..."
    umount -R /mnt 2>/dev/null || true
    
    log_step "Closing LUKS container..."
    cryptsetup close cryptsystem 2>/dev/null || true
    
    log_success "Cleanup completed!"
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
  5) Clean (unmount & close LUKS)
  6) Help
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
    
    echo ""
    prompt "Clean up and reboot now? [y/N]: " -n1
    echo
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        cleanup
        log_info "Rebooting..."
        reboot
    else
        log_info "System left mounted at /mnt"
        log_info "To cleanup later: ./setup.sh clean"
        log_info "To chroot: arch-chroot /mnt"
        log_info "To reboot: umount -R /mnt && reboot"
    fi
}

run_post() {
    log_section "Starting Post-Install Phase"
    
    local scripts=(
        "post-install/prepare.sh"
        "post-install/setup-system-snapshot.sh"
        "post-install/setup-bootloader-automate.sh"
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
            5) cleanup ;;
            6) show_usage ;;
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
            clean|cleanup) cleanup ;;
            help|--help|-h) show_usage ;;
            *) log_error "Unknown command: $1"; show_usage; exit 1 ;;
        esac
    fi
}

main "$@"
