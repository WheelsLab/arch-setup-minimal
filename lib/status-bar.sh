#!/usr/bin/env bash

# Status bar functions for live logging

update_status_bar() {
    local phase="$1"
    local status="$2"
    
    printf "\033[s"
    printf "\033[1;1H"
    printf "\033[2K"
    printf "\033[1;36m[%s]\033[0m \033[1;33m→\033[0m %s" "$phase" "$status"
    printf "\033[u"
}

clear_status_bar() {
    printf "\033[s"
    printf "\033[1;1H"
    printf "\033[2K"
    printf "\033[u"
}
