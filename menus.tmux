#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#

get_local_config() {
    #
    #  only used in this file
    #
    log_it "get_local_config()"
    normalize_bool_param "@use_bind_key_notes_in_plugins" No &&
        cfg_use_notes=true || cfg_use_notes=false
    log_it "cfg_use_notes=[$cfg_use_notes]"

    normalize_bool_param "@menus_without_prefix" "$default_no_prefix" &&
        cfg_no_prefix=true || cfg_no_prefix=false
    log_it "cfg_no_prefix=[$cfg_no_prefix]"

    #
    #  In shell script unlike in tmux, backslash needs to be doubled inside quotes.
    #
    # default_key=\\

    cfg_trigger_key=$(get_tmux_option "@menus_trigger" "$default_trigger_key")
    log_it "cfg_trigger_key=[$cfg_trigger_key]"
}

clear_cache() {
    log_it "$1" # log msg

    rm -rf "$d_cache"
    mkdir -p "$d_cache"
    echo "$tmux_vers" >"$f_cached_tmux"
}

cache_validation() {
    if [ -s "$f_cached_tmux" ]; then
        tmux_vers_in_cache="$(cat "$f_cached_tmux")"
        #
        #  Clear cache if it was not created with current tmux version,
        #  Then tag cachdir with current tmux version
        #
        [ "$tmux_vers" = "$tmux_vers_in_cache" ] || {
            clear_cache \
                "Clearing incompatible cache for tmux $tmux_vers_in_cache"
        }
    else
        clear_cache "Clearing unidentified cache"
    fi
}

#===============================================================
#
#   Main
#
#===============================================================

D_TM_BASE_PATH="$(realpath -- "$(dirname -- "$0")")"

# shellcheck source=scripts/utils.sh
. "$D_TM_BASE_PATH"/scripts/utils.sh

#
#  By printing a NL and date, its easier to keep separate runs apart
#
log_it ""
log_it "$(date)"

default_trigger_key=\\
default_no_prefix=No

get_local_config
cache_validation




params=""
# -N params cant have spaces in this plugin for rasons...
$cfg_use_notes && params="-N plugin:tmux-menus"

# if [ "$cfg_no_prefix" -eq 1 ]; then
if $cfg_no_prefix; then
    params="$params -n"
    log_it "Menus bound to: $cfg_trigger_key"
else
    log_it "Menus bound to: <prefix> $cfg_trigger_key"
fi

if tmux_vers_compare 3.0 && [ "$FORCE_WHIPTAIL_MENUS" != "1" ]; then
    cmd="$d_items/main.sh"
else
    if [ -z "$(command -v whiptail)" ]; then
        error_msg "whiptail is not installed!" 1
    fi
    cmd="$d_scripts/do_whiptail.sh"
fi

# works sans -N spaces
$TMUX_BIN bind-key "$params" "$cfg_trigger_key"  run-shell "$cmd"
