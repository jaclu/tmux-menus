#!/usr/bin/env bash
# Always sourced file - Fake bang path to help editors
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Initiate plugin, should be run in background from .tmux file
#

bind_plugin_key() {
    # shellcheck disable=SC2154 # defined in helpers_minimal.sh
    bind_cmd="$f_main_menu"
    # shellcheck disable=SC2154 # defined in cache/plugin_params
    if $cfg_use_whiptail; then
        bind_cmd="$f_ext_dlg_trigger"
        log_it "Will use alternate menu handler: $cfg_alt_menu_handler"
    fi
    cmd="bind-key"
    # shellcheck disable=SC2154 # defined in cache/plugin_params
    $cfg_use_notes && {
        # And why can't space be used in this note?
        # cmd+=" -N \"plugin ${plugin_name} trigger\""
        cmd+=" -N 'plugin ${plugin_name} trigger'"
    }
    # shellcheck disable=SC2154 # defined in cache/plugin_params
    if $cfg_no_prefix; then
        cmd+=" -n"
        trigger_sequence="Menus will be bound to: $cfg_trigger_key"
    else
        trigger_sequence="Menus will be bound to: <prefix> $cfg_trigger_key"
    fi
    cmd+=" '$cfg_trigger_key' run-shell $bind_cmd"

    # shellcheck disable=SC2154 # TMUX_MENUS_NO_DISPLAY is an env variable
    [[ "$TMUX_MENUS_NO_DISPLAY" = "1" ]] && {
        # used for debugging menu builds
        log_it "Due to TMUX_MENUS_NO_DISPLAY terminating before binding trigger key"
        exit 0
    }

    # shellcheck disable=SC2034 # used in tmux.sh
    teh_debug=true
    # tmux_error_handler bind-key -N "plugin menus" Space run-shell /Users/jaclu/git_repos/mine/tmux-menus/items/main.sh

    # shellcheck disable=SC2154 # defined in helpers_minimal.sh
    eval "$TMUX_BIN" "$cmd" || {
        error_msg "Failed to bind trigger: $cfg_trigger_key"
    }

    log_it_minimal "$trigger_sequence"
}

#===============================================================
#
#   Main
#
#===============================================================

D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck disable=SC2034 # used in helpers_minimal.sh
initialize_plugin=1

# can't read source when mixing bah & posix

# disable=SC2154,SC2001,SC2292
# shellcheck source=/dev/null
source "$D_TM_BASE_PATH"/scripts/helpers.sh

# log_it "=====   plugin_init.sh starting   ====="

# shellcheck disable=SC2154 # defined in helpers_minimal.sh
if [[ -d "$d_cache" ]]; then
    # clear out potentially obsolete cache items
    safe_remove "$f_cache_known_tmux_vers"
    safe_remove "$f_cached_tmux_options"
    safe_remove "$f_cached_tmux_key_binds" external_path_ok
    # Clear any errors from previous runs
    safe_remove "$d_cache"/error-*
    safe_remove "$d_cache"/cmd_output

    #
    # If these are removed, it can't be detected if config changed, so
    # there is no hint if cached items should be dropped or not
    #
    # "$f_cache_params"  "$f_chksum_custom"  "$f_min_display_time"
fi

#
# These will only do something during debugging, if cfg_log_file was hardcoded
# in helpers_minimal.sh or similar...
# So harmless normally really convenient when working on the code
#
log_it
log_it
log_it

config_setup

#
# If @menus_log_file was defined, it has now taken effect
# create a blank line in the log to separate tmux sessions
#
log_it

# shellcheck disable=SC2154 # defined in cache/plugin_params
if $cfg_use_cache; then
    #
    #  If custom inventory is used, update link to its main index
    #
    "$d_scripts"/update_custom_inventory.sh || {
        error_msg "update_custom_inventory.sh reported error: $?"
    }
else
    log_it "Will NOT use cache!"
fi

#
# Key is not bound until cache (if allowed) has been prepared, so normally
# no menus will be triggered by the user before this
#
bind_plugin_key
