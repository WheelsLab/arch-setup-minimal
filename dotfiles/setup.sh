#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/constants.sh"
source "$SCRIPT_DIR/../lib/logging.sh"

log_section "Setting Up Dotfiles"

HOME_DIR="${HOME}"

log_step "Creating config directories..."
mkdir -p "$HOME_DIR/.config/niri"
mkdir -p "$HOME_DIR/.config/alacritty"
mkdir -p "$HOME_DIR/.config/dms"
mkdir -p "$HOME_DIR/.config/hypr"
mkdir -p "$HOME_DIR/.local/share/fonts

log_step "Installing dotfiles from repository..."
if [[ -d "$SCRIPT_DIR/niri" ]]; then
    cp -r "$SCRIPT_DIR/niri"/* "$HOME_DIR/.config/niri/" 2>/dev/null || true
fi

if [[ -d "$SCRIPT_DIR/alacritty" ]]; then
    cp -r "$SCRIPT_DIR/alacritty"/* "$HOME_DIR/.config/alacritty/" 2>/dev/null || true
fi

if [[ -d "$SCRIPT_DIR/dms" ]]; then
    cp -r "$SCRIPT_DIR/dms"/* "$HOME_DIR/.config/dms/" 2>/dev/null || true
fi

log_step "Setting up fonts..."
if [[ -d "$SCRIPT_DIR/fonts" ]]; then
    cp -r "$SCRIPT_DIR/fonts"/* "$HOME_DIR/.local/share/fonts/" 2>/dev/null || true
    fc-cache -f
fi

log_step "Configuring shell..."
if [[ -f "$SCRIPT_DIR/zshrc" ]]; then
    cp "$SCRIPT_DIR/zshrc" "$HOME_DIR/.zshrc"
fi

if [[ -f "$SCRIPT_DIR/starship.toml" ]]; then
    cp "$SCRIPT_DIR/starship.toml" "$HOME_DIR/.config/"
fi

log_success "Dotfiles installed!"
