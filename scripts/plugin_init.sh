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
    if $cfg_use_whiptail; then
        bind_cmd="$d_scripts/external_dialog_trigger.sh"
        log_it "Will use alternate menu handler: $cfg_alt_menu_handler"
    else
        bind_cmd="$d_items/main.sh"
    fi
    cmd="bind-key"
    $cfg_use_notes && {
        # And why can't space be used in this note?
        cmd+=" -N plugin_${plugin_name}_trigger"
    }
    if $cfg_no_prefix; then
        cmd+=" -n"
        # shellcheck disable=SC2154
        trigger_sequence="Menus will be bound to: $cfg_trigger_key"
    else
        trigger_sequence="Menus will be bound to: <prefix> $cfg_trigger_key"
    fi
    cmd+=" $cfg_trigger_key  run-shell $bind_cmd"

    # shellcheck disable=SC2154
    [[ "$TMUX_MENUS_NO_DISPLAY" = "1" ]] && {
        # used for debugging menu builds
        log_it "Due to TMUX_MENUS_NO_DISPLAY terminating before binding trigger key"
        exit 0
    }

    # shellcheck disable=SC2086 # in this case we want the variable to unpack
    $TMUX_BIN $cmd || {
        error_msg_safe "Failed to bind trigger: $trigger_sequence"
    }

    log_it_minimal "$trigger_sequence"
}

#===============================================================
#
#   Main
#
#===============================================================

D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

initialize_plugin=1

# can't read source when mixing bah & posix
# shellcheck disable=SC2154,SC2001,SC2292 source=scripts/helpers_minimal.sh
source "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh

$all_helpers_sourced || source_all_helpers "always done by plugin_init.sh"

# log_it "=====   plugin_init.sh starting   ====="

if [[ -d "$d_cache" ]]; then
    # clear out potentially obsolete cache items
    safe_remove "$f_cache_known_tmux_vers"
    safe_remove "$f_cached_tmux_options"
    safe_remove "$f_cached_tmux_key_binds"

    #
    # If these are removed, it can't be detected if config changed, so
    # there is no hint if cached items should be dropped or not
    #
    # safe_remove "$f_cache_params"
    # safe_remove "$f_chksum_custom"
    # safe_remove "$f_min_display_time"
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

#
#  If custom inventory is used, update link to its main index
#
"$d_scripts"/update_custom_inventory.sh

#
# Key is not bound until cache (if allowed) has been prepared, so normally
# no menus will be triggered by the user before this
#
bind_plugin_key
