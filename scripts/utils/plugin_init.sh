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

print_stderr() {
    [[ -t 0 ]] && {
        echo "$1" >/dev/stderr
    }
}

log_basic() {
    if log_file_writeable; then
        log_it "$1"
    else
        print_stderr "[bl] $1"
        $TMUX_BIN display-message "[$plugin_name]$1"
    fi
}

error_basic() {
    # Used before the env is setup, and normal error handling is unavailable
    _err_msg="ERROR: $plugin_name - $1"
    if log_file_writeable; then
        log_it "$_err_msg"
    else
        print_stderr "$_err_msg"
    fi
    $TMUX_BIN display-message "ERROR: [$plugin_name][bl] $1"
    exit 1
}

log_file_unset() {
    cfg_log_file=""
}

log_file_writeable() {
    # if it is undefined or absent assume it can't be used
    # log_basic "log_file_writeable()"
    [[ -z "$cfg_log_file" ]] && [[ ! -f "$cfg_log_file" ]] && {
        print_stderr "log_file_writeable() -  log_file undefined or missing: $cfg_log_file"
        return 1
    }
    _d_log="$(dirname -- "$cfg_log_file")"
    if [[ -z "$_d_log" ]] || [[ ! -d "$_d_log" ]]; then
        # folder for logfile undefined or missing
        log_file_unset
        print_stderr "log_file_writeable() -  WARNING: log folder missing: $_d_log"
        return 1
    fi
    touch "$cfg_log_file" || {
        # failed to write to log_file
        log_file_unset
        print_stderr "log_file_writeable() -  Unable to write to: $cfg_log_file"
        return 1
    }
    return 0
}

#---------------------------------------------------------------
#
#   setup plugin
#
#---------------------------------------------------------------

get_config_refresh() {
    #
    #  Retrieves cached env params, rebuilding the cache if tmux conf was
    #  more recent, or not found
    #
    log_basic "get_config_refresh()"
    # profiling_display "[helpers] get_config_refresh()"

    # _m="><> get_config_refresh(), start -"
    # _m="$_m tpt_current_vers [$tpt_current_vers]"
    # _m="$_m tpt_current_vers_i [$tpt_current_vers_i]"
    # _m="$_m tpt_current_vers_suffix [$tpt_current_vers_suffix]"
    # log_basic "$_m"

    [[ -f "$f_cache_params" ]] && {
        # Only really need cfg_tmux_conf at this point
        log_basic "><> attempting to source: $f_cache_params"
        # shellcheck source=cache/plugin_params
        . "$f_cache_params" || {
            log_basic "WARNING: Failed to source: $f_cache_params, removing it"
            rm -f "$f_cache_params"
        }
        log_basic "reading cfg_tmux_conf - sourced: $f_cache_params"
    }

    [[ -z "$cfg_tmux_conf" ]] && {
        log_basic "><> get_config_refresh() - will get option: @menus_config_file [$default_tmux_conf]"
        tmux_get_option cfg_tmux_conf "@menus_config_file" "$default_tmux_conf"
    }

    [[ -z "$tpt_current_vers" ]] && exit 1

    if [[ -f "$cfg_tmux_conf" ]] && [[ -f "$f_cache_params" ]]; then
        #
        # if the wrong tmux conf was provided, don't see it as an error, just
        # skip checking age of config file vs cache
        #
        [[ -n "$(find "$cfg_tmux_conf" -newer "$f_cache_params" 2>/dev/null)" ]] && {
            log_basic "$cfg_tmux_conf has been updated, parse again for current settings"
            get_config_uncached
        }
    else
        # Failed to find tmux conf, but since this is plugin init, play it safe
        # and recreate param cache

        log_basic "tmux conf and cache could not be verified, manually updating cache"
        get_config_uncached
    fi
}

prepare_cach() {
    if $cfg_use_cache; then
        cache_add_ok_vers "$tpt_current_vers"

        if [[ -d "$d_custom_items" ]]; then
            $f_update_custom_inventory
        fi
    else
        log_basic "-->  cache is disabled!  <--"
    fi
}

bind_plugin_key() {
    if $cfg_use_whiptail; then
        bind_cmd="$d_scripts/external_dialog_trigger.sh"
        log_basic "alternate menu handler: $cfg_alt_menu_handler"
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

    # shellcheck disable=SC2154
    [[ "$TMUX_MENUS_NO_DISPLAY" = "1" ]] && {
        # used for debugging menu builds
        log_basic "Due to TMUX_MENUS_NO_DISPLAY terminating before binding trigger key"
        exit 0
    }

    # shellcheck disable=SC2086 # in this case we want the variable to unpack
    $TMUX_BIN $cmd || {
        error_msg_safe "Failed to bind trigger: $trigger_sequence"
    }

    log_basic "$trigger_sequence"
}

#===============================================================
#
#   Main
#
#===============================================================

D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(dirname -- "$(realpath "$0")")")")"

initialize_plugin=1

# can't read source when mixing bah & posix
# shellcheck disable=SC2154,SC2001,SC2292 source=scripts/helpers.sh
. "$D_TM_BASE_PATH"/scripts/helpers.sh

$all_helpers_sourced || source_all_helpers "always done by menus.tmux"

if [[ -d "$d_cache" ]]; then
    d_work_space="$d_cache"
    # clear out obsolete cache items
    # rm -f "$f_cached_tmux_options"
else
    d_work_space="$(mktemp -d -t "tmux-menus-$(id -u)-$$-XXXX")"
    [[ -z "$d_work_space" ]] && error_basic "Failed to create temp workspace"
    log_basic "d_work_space: $d_work_space"
fi

# Create a LF in log_file to easier separate runs
log_file_writeable && log_basic

get_config_refresh

prepare_cach
bind_plugin_key
