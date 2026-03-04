#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/constants.sh"
source "$SCRIPT_DIR/lib/logging.sh"
source "$SCRIPT_DIR/lib/utils.sh"

log_section "Installing System Packages"

log_step "Updating system..."
sudo pacman -Syu --noconfirm

log_step "Installing Xorg and Wayland..."
sudo pacman -S --noconfirm \
    xorg-server \
    xorg-xinit \
    wayland \
    wayland-protocols \
    wlroots \
    seatd

log_step "Installing Niri and related packages..."
sudo pacman -S --noconfirm \
    niri \
    scdoc \
    pkg-config \
    libpixman-1.0 \
    libxkbcommon-x11 \
    libxkbcommon \
    libegl1 \
    libglvnd \
    libinput \
    libudev \
    hikari \
    cage

log_step "Installing terminal and shell..."
sudo pacman -S --noconfirm \
    alacritty \
    foot \
    starship \
    zsh \
    zsh-completions

log_step "Installing font packages..."
sudo pacman -S --noconfirm \
    noto-fonts \
    noto-fonts-cjk \
    noto-fonts-emoji \
    ttf-jetbrains-mono \
    ttf-nerd-fonts-symbols

log_step "Installing audio packages..."
sudo pacman -S --noconfirm \
    pipewire \
    wireplumber \
    pipewire-pulse \
    pavucontrol

log_step "Installing network and utility packages..."
sudo pacman -S --noconfirm \
    networkmanager \
    network-manager-applet \
    blueman \
    bluez \
    bluez-utils \
    cups \
    cups-pdf \
    printer-utility \
    thermald

log_step "Installing Chinese input method..."
sudo pacman -S --noconfirm \
    fcitx5 \
    fcitx5-chinese-addons \
    fcitx5-qt \
    fcitx5-gtk \
    fcitx5-configtool

log_step "Installing AUR packages..."
paru -S --noconfirm \
    ttf-symbola \
    nerdfonts \
    papirus-icon-theme \
    bibata-cursor-theme

log_step "Enabling services..."
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable cups

log_success "System packages installed!"
