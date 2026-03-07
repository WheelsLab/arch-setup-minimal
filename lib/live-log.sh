#!/usr/bin/env bash

# Live logging functions for real-time progress display

CURRENT_PHASE="${CURRENT_PHASE:-Running}"
LOG_FILE="${LOG_FILE:-/tmp/setup.log}"

source "$(dirname "${BASH_SOURCE[0]}")/status-bar.sh"

run_live() {
    local description="$1"
    shift
    
    update_status_bar "$CURRENT_PHASE" "$description..."
    
    if "$@" 2>&1 | tee -a "$LOG_FILE"; then
        update_status_bar "$CURRENT_PHASE" "$description \033[32mDone\033[0m"
        return 0
    else
        update_status_bar "$CURRENT_PHASE" "$description \033[31mFailed\033[0m"
        return 1
    fi
}

run_live_silent() {
    local description="$1"
    shift
    
    update_status_bar "$CURRENT_PHASE" "$description..."
    
    if "$@" >> "$LOG_FILE" 2>&1; then
        update_status_bar "$CURRENT_PHASE" "$description \033[32mDone\033[0m"
        return 0
    else
        update_status_bar "$CURRENT_PHASE" "$description \033[31mFailed\033[0m"
        return 1
    fi
}

run_live_summary() {
    local description="$1"
    shift
    local start_time
    
    update_status_bar "$CURRENT_PHASE" "$description..."
    start_time=$(date +%s)
    
    if "$@" 2>&1 | tail -5 | tee -a "$LOG_FILE"; then
        local elapsed=$(($(date +%s) - start_time))
        update_status_bar "$CURRENT_PHASE" "$description \033[32mDone\033[0m (\033[36m${elapsed}s\033[0m)"
        return 0
    else
        update_status_bar "$CURRENT_PHASE" "$description \033[31mFailed\033[0m"
        return 1
    fi
}

finish_phase() {
    clear_status_bar
}
