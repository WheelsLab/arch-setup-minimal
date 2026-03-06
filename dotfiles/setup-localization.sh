#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/constants.sh"
source "$SCRIPT_DIR/../lib/logging.sh"
source "$SCRIPT_DIR/../lib/utils.sh"

trap 'log_error "Script failed at line $LINENO: $BASH_COMMAND" && exit 1' ERR

log_section "Configuring Chinese Localization"

log_step "Configuring system locale..."
sudo sed -i '/^#en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen
sudo sed -i '/^#zh_CN.UTF-8 UTF-8/s/^#//' /etc/locale.gen
sudo locale-gen
echo "LANG=zh_CN.UTF-8" | sudo tee /etc/locale.conf > /dev/null

log_step "Installing Fcitx5 and Chinese addons..."
sudo pacman -S --noconfirm fcitx5-im fcitx5-chinese-addons

log_step "Installing Rime input method..."
if check_command yay; then
    yay -S --noconfirm fcitx5-rime rime-ice-git fcitx5-material-color
elif check_command paru; then
    paru -S --noconfirm fcitx5-rime rime-ice-git fcitx5-material-color
else
    log_error "No AUR helper (yay/paru) found"
    exit 1
fi

log_step "Installing Chinese fonts..."
sudo pacman -S --noconfirm adobe-source-han-serif-cn-fonts wqy-zenhei
sudo pacman -S --noconfirm noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra

log_step "Installing programming fonts..."
if check_command yay; then
    yay -S --noconfirm ttf-maplemono-nf-cn-unhinted ttf-iosevkaterm ttf-sarasa-gothic-nerd-fonts
elif check_command paru; then
    paru -S --noconfirm ttf-maplemono-nf-cn-unhinted ttf-iosevkaterm ttf-sarasa-gothic-nerd-fonts
else
    log_error "No AUR helper (yay/paru) found"
    exit 1
fi

log_success "Chinese localization setup completed!"
echo ""
echo "Add to ~/.xprofile:"
echo "  export GTK_IM_MODULE=fcitx5"
echo "  export QT_IM_MODULE=fcitx5"
echo "  export XMODIFIERS=@im=fcitx5"
echo "  fcitx5 -d"
