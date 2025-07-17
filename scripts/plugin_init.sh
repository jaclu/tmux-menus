#!/bin/sh
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
        cmd="$cmd -N 'plugin ${plugin_name} trigger'"
    }
    # shellcheck disable=SC2154 # defined in cache/plugin_params
    if $cfg_no_prefix; then
        cmd="$cmd -n"
        trigger_sequence="Menus will be bound to: $cfg_trigger_key"
    else
        trigger_sequence="Menus will be bound to: <prefix> $cfg_trigger_key"
    fi
    cmd="$cmd '$cfg_trigger_key' run-shell $bind_cmd"

    # shellcheck disable=SC2154 # TMUX_MENUS_NO_DISPLAY is an env variable
    [ "$TMUX_MENUS_NO_DISPLAY" = "1" ] && {
        # used for debugging menu builds
        log_it "Due to TMUX_MENUS_NO_DISPLAY terminating before binding trigger key"
        exit 0
    }

    [ ! -f "$f_skip_low_tmux_version_warning" ] && ! tmux_vers_check 1.8 && {
        # shellcheck disable=SC2154 # current_tmux_vers is an env variable
        msg="Due to tmux($current_tmux_vers) < 1.8 user options can not be processed.\n\n"
        msg="{$msg}The tmux-menus plugin will be bound to its default key: $cfg_trigger_key"
        msg="{$msg} \n\n'All other options will also use their defaults.\n\n'"
        msg="{$msg}  tools/show_config.sh will display current settings.\n\n"
        msg="{$msg}To avoid seeing this message again - do:\n"
        msg="{$msg}  touch $f_skip_low_tmux_version_warning"
        display_formatted_message "$msg"
    }

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

f_skip_low_tmux_version_warning="$D_TM_BASE_PATH"/.skip_old_tmux_warning

# shellcheck source=/dev/null # can't read source when mixing bah & posix
. "$D_TM_BASE_PATH"/scripts/helpers.sh

# log_it "=====   plugin_init.sh starting   ====="

# Define cfg_use_cache as soon as possible
# shellcheck disable=SC2154 # default_use_cache defined in tmux.sh
if normalize_bool_param "@menus_use_cache" "$default_use_cache"; then
    cfg_use_cache=true
else
    # shellcheck disable=SC2034 # cfg_use_cache used to define cache/plugin_params
    cfg_use_cache=false
fi

# shellcheck disable=SC2154 # d_cache defined in helpers_minimal.sh
if [ "$cfg_use_cache" = true ] && [ -d "$d_cache" ]; then
    # clear out potentially obsolete cache items
    safe_remove "$f_cached_tmux_options" "plugin_init.sh"
    safe_remove "$f_cached_tmux_key_binds" "plugin_init.sh" external_path_ok
    # Clear any errors from previous runs
    safe_remove "$d_cache"/error-* "plugin_init.sh"
    safe_remove "$d_cache"/cmd_output "plugin_init.sh"
    #
    # If these are removed, it can't be detected if config changed, so
    # there is no hint if cached items should be dropped or not
    #
    # "$f_cache_params"  "$f_chksum_custom"  "$f_min_display_time"
fi

#
# These will only do something during debugging, if cfg_log_file was hardcoded
# in helpers_minimal.sh or similar...
# So normally silent, and really convenient when working on the code
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
