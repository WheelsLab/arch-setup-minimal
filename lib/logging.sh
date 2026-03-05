#!/usr/bin/env bash

# Logging functions for Arch Linux minimal setup

[[ -z "$COLOR_NC" ]] && source "$(dirname "${BASH_SOURCE[0]}")/constants.sh"

LOG_FILE="${LOG_FILE:-/tmp/setup.log}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"

log_debug() {
    [[ "$LOG_LEVEL" == "DEBUG" ]] && log "DEBUG" "$@"
}

log_info() {
    log "INFO" "$@"
}

log_warn() {
    echo -e "${COLOR_RED}[!] $*${COLOR_NC}" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${COLOR_RED}[✗] $*${COLOR_NC}" | tee -a "$LOG_FILE" >&2
}

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

log_section() {
    local title="$1"
    echo "" | tee -a "$LOG_FILE"
    echo "========================================" | tee -a "$LOG_FILE"
    echo "  $title" | tee -a "$LOG_FILE"
    echo "========================================" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${COLOR_GREEN}[✓]${COLOR_NC} $*" | tee -a "$LOG_FILE"
}

log_fail() {
    echo -e "${COLOR_RED}[✗]${COLOR_NC} $*" | tee -a "$LOG_FILE"
}

log_step() {
    echo -e "${COLOR_BLUE}[→]${COLOR_NC} $*" | tee -a "$LOG_FILE"
}

log_warn_yellow() {
    echo -e "${COLOR_YELLOW}[!]${COLOR_NC} $*" | tee -a "$LOG_FILE"
}

prompt() {
    local prompt_text="$1"
    local opts=""
    if [[ "$2" == "-s" ]]; then
        opts="-s"
    fi
    read $opts -rp "${COLOR_ORANGE}$prompt_text${COLOR_NC} " "${@:2}"
}

confirm() {
    local prompt="${1:-Continue?}"
    local default="${2:-n}"
    
    local yn
    if [[ "$default" == "y" ]]; then
        read -p "$prompt [Y/n]: " yn
        [[ -z "$yn" ]] && yn="y"
    else
        read -p "$prompt [y/N]: " yn
        [[ -z "$yn" ]] && yn="n"
    fi
    
    [[ "$yn" =~ ^[Yy]$ ]]
}

init_log() {
    LOG_FILE="${1:-/tmp/setup.log}"
    echo "========================================" >> "$LOG_FILE"
    echo "  Log initialized: $(date)" >> "$LOG_FILE"
    echo "========================================" >> "$LOG_FILE"
}
