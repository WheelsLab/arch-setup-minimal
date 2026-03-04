#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/constants.sh"
source "$SCRIPT_DIR/lib/logging.sh"
source "$SCRIPT_DIR/lib/utils.sh"

check_root
log_section "Final Chroot Configuration"

MOUNT_ROOT="${MOUNT_POINT_ROOT}"

log_info "You can now chroot into the system with:"
log_info "  arch-chroot $MOUNT_ROOT"
log_info ""
log_info "Post-install steps:"
log_info "  1. Configure network: systemctl enable NetworkManager"
log_info "  2. Enable sudo for your user"
log_info "  3. Install desktop environment"
log_info "  4. Reboot"
log_info ""
log_info "To exit chroot and continue: exit"
log_info "Then run: umount -R $MOUNT_ROOT"

read -p "Press Enter to chroot into the system..." 

arch-chroot "$MOUNT_ROOT"
