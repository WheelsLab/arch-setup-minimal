#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/constants.sh"
source "$SCRIPT_DIR/lib/logging.sh"
source "$SCRIPT_DIR/lib/utils.sh"

log_section "Configuring Snapper Snapshots"

log_step "Installing snapper..."
sudo pacman -S --noconfirm snapper

log_step "Creating snapper config for root..."
sudo snapper -c root create-config /

log_step "Configuring snapper..."
sudo cat > /etc/snapper/configs/root <<'EOF'
SUBVOLUME="/"
ALLOW_USERS=""
ALLOW_GROUPS=""
QGROUP=""
SPACE_LIMIT="0.1"
FREE_LIMIT="0.2"
NUMBER_LIMIT="10"
NUMBER_LIMIT_IMPORTANT="5"
TIMELINE_LIMIT="10"
TIMELINE_LIMIT_IMPORTANT="5"
TIMELINE_CREATE="no"
MIN_AGE="1800"
EOF

log_step "Enabling snapper-timeline.timer..."
sudo systemctl enable snapper-timeline.timer
sudo systemctl start snapper-timeline.timer

log_step "Enabling snapper-cleanup.timer..."
sudo systemctl enable snapper-cleanup.timer
sudo systemctl start snapper-cleanup.timer

log_step "Creating initial snapshot..."
sudo snapper -c root create --description "initial setup"

log_success "Snapper configured!"
