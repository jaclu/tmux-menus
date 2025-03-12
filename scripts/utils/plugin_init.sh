#!/usr/bin/env bash
# Always sourced file - Fake bang path to help editors
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Try to init the cache if allowed

#---------------------------------------------------------------
#
#   tmux version related support functions
#
#---------------------------------------------------------------

basic_log() {
    if log_file_writeable; then
        log_it "$1"
    else
        _m="[bl] $1"
       [[ -t 0 ]] && {
            echo "$1">/dev/stderr
        }
        # shellcheck disable=SC2154
        $TMUX_BIN display-message "[$plugin_name]$1"
    fi
}

basic_err() {
    # Used before the env is setup, and normal error handling is unavailable
    err_msg="ERROR: $plugin_name - $1"
    if log_file_writeable; then
        log_it "$err_msg"
    else
       [[ -t 0 ]] && {
            echo "$err_msg" >/dev/stderr
        }
    fi
    $TMUX_BIN display-message "ERROR: [$plugin_name][bl] $1"
    exit 1
}

log_file_unset() {
    cfg_log_file=""
}

prepare_cach() {
    # shellcheck disable=SC2154
    if $cfg_use_cache; then
        # shellcheck disable=SC2154
        cache_add_ok_vers "$tpt_current_vers"

        # shellcheck disable=SC2154
        if [[ -d "$d_custom_items" ]]; then
            $f_update_custom_inventory
        fi
    else
        log_it "-->  cache is disabled!  <--"
    fi
}

log_file_writeable() {
    # if it is undefined or absent assume it can't be used
    [[ -z "$cfg_log_file" ]] && [[ ! -f "$cfg_log_file" ]] && return 1

    _d_log="$(dirname -- "$cfg_log_file")"
    if [[ -z "$_d_log" ]] || [[ ! -d "$_d_log" ]]; then
        # folder for logfile undefined or missing
        log_file_unset
        return 1
    fi
    touch "$cfg_log_file" || {
        # failed to write to log_file
        log_file_unset
        return 1
    }
    echo "><> cfg_log_file: $cfg_log_file" >/dev/stderr
    return 0
}

#---------------------------------------------------------------
#
#   setup plugin
#
#---------------------------------------------------------------

bind_plugin_key() {
    if $cfg_use_whiptail; then
        bind_cmd="$d_scripts/external_dialog_trigger.sh"
        log_it "alternate menu handler: $cfg_alt_menu_handler"
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
        trigger_sequence="Menus bound to: $cfg_trigger_key"
    else
        trigger_sequence="Menus bound to: <prefix> $cfg_trigger_key"
    fi
    cmd+=" $cfg_trigger_key  run-shell $bind_cmd"

    [[ "$TMUX_MENUS_NO_DISPLAY" = "1" ]] && {
        # used for debugging menu builds
        log_it "Due to TMUX_MENUS_NO_DISPLAY terminating before binding trigger key"
        exit 0
    }

    # shellcheck disable=SC2086 # in this case we want the variable to unpack
    $TMUX_BIN $cmd || {
        error_msg_safe "Failed to bind trigger: $trigger_sequence"
    }

    log_it "$trigger_sequence"
}

#===============================================================
#
#   Main
#
#===============================================================

D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(dirname -- "$(realpath "$0")")")")"

# shellcheck disable=SC2034
initialize_plugin=1

# shellcheck source=/dev/null  # can't read source when mixing bah & posix
. "$D_TM_BASE_PATH"/scripts/helpers.sh

# shellcheck disable=SC2154
$all_helpers_sourced || source_all_helpers "always done by menus.tmux"

# log_interactive_to_stderr=0

# shellcheck disable=SC2154
if [[ -d "$d_cache" ]]; then
    d_work_space="$d_cache"
    # clear out obsolete cache items
    # rm -f "$f_cached_tmux_options"
else
    # shellcheck disable=SC2154
    d_work_space="$(mktemp -d -t "tmux-menus-$(id -u)-$$-XXXX")"
    [[ -z "$d_work_space" ]] && err_basic "Failed to create temp workspace"
fi


# Create a LF in log_file to easier separate runs
# log_it
log_file_writeable && log_it

# exit 1
get_config_refresh

prepare_cach
bind_plugin_key
