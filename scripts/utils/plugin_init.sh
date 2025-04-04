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

get_config_refresh() {
    #
    #  Retrieves cached env params, rebuilding the cache if tmux conf was
    #  more recent, or not found
    #
    # log_it "get_config_refresh()"

    [[ -f "$f_cache_params" ]] && {
        # [[ "$log_file_forced" = 1 ]] && orig_log_file="$cfg_log_file"

        # Only really need cfg_tmux_conf at this point
        source_cached_params || {
            _m="WARNING: get_config_refresh() Failed to source: $f_cache_params,"
            _m+=" removing it"
            log_it "$_m"
            safe_remove "$f_cache_params"
        }
        # log_it "reading cfg_tmux_conf - sourced: $f_cache_params"
    }

    [[ -z "$cfg_tmux_conf" ]] && {
        tmux_get_option cfg_tmux_conf "@menus_config_file" "$default_tmux_conf"
    }
    if [[ -f "$cfg_tmux_conf" ]] && [[ -f "$f_cache_params" ]]; then
        #
        # if the wrong tmux conf was provided, don't see it as an error, just
        # skip checking age of config file vs cache
        #

        if [[ -n "$(find "$cfg_tmux_conf" -newer "$f_cache_params" 2>/dev/null)" ]]; then
            # log_it "$cfg_tmux_conf has been updated, parse again for current settings"
            get_config_read_save_if_uncached
        else
            check_speed_cutoff 0.1
        fi
    else
        # Failed to find tmux conf, but since this is plugin init, play it safe
        # and recreate param cache

        # log_it "tmux conf and cache could not be verified, manually updating cache"
        get_config_read_save_if_uncached
    fi
    check_speed_cutoff 1
}

prepare_cache() {
    # log_it "prepare_cache() current_tmux_vers"

    # dummy check to get current vers, 0.0 is often used in dialogs, so not a wasted
    # effort to cache it as valid
    tmux_vers_check 0.0

    if $cfg_use_cache; then
        cache_add_ok_vers "$current_tmux_vers"
        [[ -f "$f_update_custom_inventory" ]] && $f_update_custom_inventory
    else
        log_it "-->  cache is disabled!  <--"
    fi
}

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
        # shellcheck disable=SC2154
        trigger_sequence="Menus bound to: $cfg_trigger_key"
    else
        trigger_sequence="Menus bound to: <prefix> $cfg_trigger_key"
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

    log_it "$trigger_sequence"
}

#===============================================================
#
#   Main
#
#===============================================================

D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(dirname -- "$(realpath "$0")")")")"

initialize_plugin=1

# can't read source when mixing bah & posix
# shellcheck disable=SC2154,SC2001,SC2292 source=scripts/helpers_minimal.sh
. "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh

$all_helpers_sourced || source_all_helpers "always done by plugin_init.sh"

if [[ -d "$d_cache" ]]; then
    # clear out potentially obsolete cache items
    safe_remove "$f_cached_tmux_options"
    safe_remove "$f_cache_known_tmux_vers"

    #
    # If these are removed, it can't be detected if config changed, so
    # there is no hint if cached items should be dropped or not
    #
    # safe_remove "$f_cache_params"
    # safe_remove "$f_chksum_custom"
    # safe_remove "$f_min_display_time"
fi

safe_now t_init_start # get a feel for if this is a slow system...

# Create a LF in log_file to easier separate runs
log_it

get_config_refresh

#
# Setup a hint for how short a menu display is indicating screen to small
# for normal systems this can be really low, for slower it needs to allow
# for the time needed to generate the menu
#

prepare_cache

#
# Key is not bound until cache (if allowed) has been prepared, so normally
# no menus will be triggered by the user before this
#
bind_plugin_key
