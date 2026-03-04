#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/constants.sh"
source "$SCRIPT_DIR/lib/logging.sh"
source "$SCRIPT_DIR/lib/utils.sh"

log_section "Configuring Desktop Environment"

DOTFILES_DIR="$SCRIPT_DIR/dotfiles"
HOME_DIR="$HOME"

log_step "Setting up Niri configuration..."
mkdir -p "$HOME_DIR/.config/niri"
if [[ -f "$DOTFILES_DIR/niri/config.kdl" ]]; then
    cp "$DOTFILES_DIR/niri/config.kdl" "$HOME_DIR/.config/niri/"
fi

log_step "Setting up DankMaterialShell..."
if [[ -d "$DOTFILES_DIR/dms" ]]; then
    git clone https://github.com/MarianArredondo/DankMaterialShell.git /tmp/dms
    cd /tmp/dms
    ./install.sh
fi

log_step "Configuring Alacritty..."
mkdir -p "$HOME_DIR/.config/alacritty"
if [[ -f "$DOTFILES_DIR/alacritty/alacritty.toml" ]]; then
    cp "$DOTFILES_DIR/alacritty/alacritty.toml" "$HOME_DIR/.config/alacritty/"
fi

log_step "Configuring Starship prompt..."
if [[ -f "$DOTFILES_DIR/starship.toml" ]]; then
    cp "$DOTFILES_DIR/starship.toml" "$HOME_DIR/.config/"
else
    mkdir -p "$HOME_DIR/.config"
    cat > "$HOME_DIR/.config/starship.toml" <<'EOF'
add_newline = false
format = "$directory$git_branch$git_status$character"

[character]
success_symbol = "[➜](bold green)"
error_symbol = "[✗](bold red)"

[directory]
truncation_length = 3
truncate_to_repo = true
EOF
fi

log_step "Setting up zsh..."
if [[ ! -f "$HOME_DIR/.zshrc" ]]; then
    cat > "$HOME_DIR/.zshrc" <<'EOF'
# Enable Powerlevel10k
#autoload -U promptinit; promptinit

# Starship prompt
eval "$(starship init zsh)"

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Key bindings
bindkey -e

# Aliases
alias ls='eza --icons'
alias ll='eza -la --icons'
alias la='eza -a --icons'
alias cat='bat'

# Path
export PATH="$HOME/.local/bin:$PATH"

# Fcitx5
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx
EOF
fi

log_step "Creating .xprofile for session startup..."
cat > "$HOME_DIR/.xprofile" <<'EOF'
#!/bin/sh
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx

fcitx5 -d &

exec niri
EOF
chmod +x "$HOME_DIR/.xprofile"

log_step "Setting up XDG user directories..."
xdg-user-dirs-update

log_success "Desktop environment configured!"
