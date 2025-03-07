#!/bin/sh
# Always sourced file - Fake bang path to help editors
# shellcheck disable=SC2034,SC2154

#
#   Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Minimal support functions, enough when caches is used and cache is available
#  All support functions will be sourced if needed, all to improve performance
#

log_it() {
    #  early abort if no logging, should not be needed, but might improve
    #  performance?
    # [ "$log_interactive_to_stderr" != "1" ] && [ -z "$cfg_log_file" ] && return

    [ "$log_interactive_to_stderr" = "1" ] && [ -t 0 ] && {
        # log to stderr if in interactive mode
        printf "[%s] log: %s\n" "$(date '+%H:%M:%S')" "$@" >/dev/stderr
        return
    }

    [ -n "$cfg_log_file" ] && {
        # log to file
        printf "[%s] %s\n" "$(date '+%H:%M:%S')" "$@" >>"$cfg_log_file"
    }
}

safe_error_msg() {
    log_it "safe_error_msg()"
    $all_helpers_sourced || source_all_helpers "safe_error_msg()"
    error_msg "$@"
}

source_all_helpers() {
    log_it
    log_it "--------------->  source_all_helpers($0)  <---------------"
    log_it "  caller: $1"
    $all_helpers_sourced && {
        # safe to call since all helpers have been sourced
        error_msg "source_all_helpers() called when it was already done"
    }
    # exit 1

    all_helpers_sourced=true # set it early to avoid recursion

    dbg_t_update "[helpers] sourcing helpers"
    #_d="${D_TM_BASE_PATH:-/tmp}"
    # shellcheck source=scripts/utils/helpers-full.sh
    . "$D_TM_BASE_PATH"/scripts/utils/helpers-full.sh
    dbg_t_update "[helpers] sourcing helpers - done"

    dbg_t_update "[helpers] ----->  source_all_helpers() - done  <-----"
}

safe_now() {
    log_it "safe_now()" # with cache:
    #
    #  MacOS date only display whole seconds, if gdate (GNU-date) is
    #  installed, it can  display times with more precision
    #
    if [ -d /proc ] && [ -f /proc/version ]; then
        #  On Linux the native date supports sub second precision
        #  unless its the busybox date - only gives seconds...
        date +%s.%N
    else
        # Running on macOS
        if [ -n "$(command -v gdate)" ]; then
            gdate +%s.%N
        else
            date +%s
        fi
    fi
}


relative_path() {
    # log_it "helpers:relative_path($1)" # with cache:

    # remove D_TM_BASE_PATH prefix
    # shellcheck disable=SC2154
    echo "$1" | sed "s|^$D_TM_BASE_PATH/||"
}

get_config() { # tmux stuff
    #
    #  The plugin init .tmux script should NOT depend on this!
    #  This is used by everything else sourcing helpers.sh, then trusting
    #  that the param cache is valid if found
    #
    log_it "get_config()" # with cache: termux, ipad

    if [ -f "$f_no_cache_hint" ]; then
        # probably not needed at this point, further optimization needed...
        $all_helpers_sourced || source_all_helpers "get_config() found: $f_no_cache_hint"

        # not using cache, read all cfg variables
        tmux_get_plugin_options
        dbg_t_update "[helpers] - tmux_get_plugin_options() done"

    elif ! cache_get_params; then
        $all_helpers_sourced || {
            source_all_helpers "get_config() cache_get_params returned false"
        }

        # Re-generate cache params
        cache_update_param_cache
        dbg_t_update "[helpers] - cache_update_param_cache() done"
    fi
}

tmux_select_menu_handler() {
    # support old env variable, cam be deleted eventually 241220
    log_it "><> tmux_select_menu_handler()"
    # [ -n "$FORCE_WHIPTAIL_MENUS" ] && TMUX_MENU_HANDLER="$FORCE_WHIPTAIL_MENUS"

    #
    # If an older version is used, or TMUX_MENU_HANDLER is 1/2
    # set cfg_use_whiptail true
    #
    if ! tmux_vers_check 3.0; then
        if command -v whiptail >/dev/null; then
            cfg_alt_menu_handler=whiptail
            log_it "tmux below 3.0 - using: whiptail"
        elif command -v dialog >/dev/null; then
            cfg_alt_menu_handler=dialog
            log_it "tmux below 3.0 - using: dialog"
        else
            safe_error_msg "Neither whiptail or dialog found, plugin aborted"
        fi
        cfg_use_whiptail=true
    elif [ "$TMUX_MENU_HANDLER" = 1 ]; then
        _cmd=whiptail
        if command -v "$_cmd" >/dev/null; then
            cfg_alt_menu_handler="$_cmd"
        else
            safe_error_msg "$_cmd not available, plugin aborted"
        fi
        cfg_use_whiptail=true
        log_it "$_cmd is selected due to TMUX_MENU_HANDLER=1"
        unset _cmd
    elif [ "$TMUX_MENU_HANDLER" = 2 ]; then
        _cmd=dialog
        if command -v "$_cmd" >/dev/null; then
            cfg_alt_menu_handler="$_cmd"
        else
            safe_error_msg "$_cmd not available, plugin aborted"
        fi
        cfg_use_whiptail=true
        log_it "$_cmd is selected due to TMUX_MENU_HANDLER=2"
        unset _cmd
    else
        cfg_use_whiptail=false
    fi
}

#---------------------------------------------------------------
#
#   tmux version related support functions
#
#---------------------------------------------------------------

cache_get_params() {
    #
    #  Retrieves cached env params, returns true on success, otherwise false
    #
    log_it "cache_get_params()"
    $cfg_use_cache || safe_error_msg "cache_get_params() - called when not using cache"
    if [ -f "$f_cache_params" ]; then
        # shellcheck disable=SC1090
        . "$f_cache_params" || return 1
        if [ -f "$cfg_tmux_conf" ] &&
            #
            # if the wrong tmux conf was provided, don't see it as an error, just
            # skip checking age of config file vs cache
            #
            [ -n "$(find "$cfg_tmux_conf" -newer "$f_cache_params" 2>/dev/null)" ]; then
            log_it "$cfg_tmux_conf has been updated, parse again for current settings"
            $all_helpers_sourced || source_all_helpers "cache_get_params()"
            cache_update_param_cache
        fi
        cache_params_retrieved=1
        log_it "><> cache_params_retrieved"
        return 0
    fi
    return 1
}

#---------------------------------------------------------------
#
#   tmux version related support functions
#
#---------------------------------------------------------------

tmux_vers_check() {
    _v_comp="$1" # Desired minimum version to check against
    log_it "><> tmux_vers_check($_v_comp) $0"

    # Retrieve and cache the current tmux version on the first call
    if [ -z "$tpt_current_vers" ] || [ -z "$tpt_current_vers_i" ]; then
        tpt_retrieve_running_tmux_vers
    fi

    $cfg_use_cache && {
        [ -z "$cached_ok_tmux_versions" ] && [ -f "$f_cache_known_tmux_vers" ] && {
            #
            # get known good/bad versions if this hasn't been sourced yet
            #
            # shellcheck source=/dev/null
            . "$f_cache_known_tmux_vers"
        }
        case "$cached_ok_tmux_versions $tvc_v_ref " in
        *"$_v_comp "*) return 0 ;;
        *) ;;
        esac
        case "$cached_bad_tmux_versions" in
        *"$_v_comp "*) return 1 ;;
        *) ;;
        esac
    }

    $all_helpers_sourced || {
        source_all_helpers "tmux_vers_check() - non-cached version"
    }

    # Compare numeric parts first for quick decisions.
    _i_comp="$(tpt_digits_from_string "$_v_comp")"
    [ "$_i_comp" -lt "$tpt_current_vers_i" ] && {
        cache_add_ok_vers "$_v_comp"
        return 0
    }
    [ "$_i_comp" -gt "$tpt_current_vers_i" ] && {
        cache_add_bad_vers "$_v_comp"
        return 1
    }

    # Compare suffixes only if numeric parts are equal.
    _suf="$(tpt_tmux_vers_suffix "$_v_comp")"
    # - If no suffix is required or suffix matches, return success
    [ -z "$_suf" ] || [ "$_suf" = "$tpt_current_vers_suffix" ] && {
        cache_add_ok_vers "$_v_comp"
        return 0
    }
    # If the desired version has a suffix but the running version doesn't, fail
    [ -n "$_suf" ] && [ -z "$tpt_current_vers_suffix" ] && {
        cache_add_bad_vers "$_v_comp"
        return 1
    }
    # Perform lexicographical comparison of suffixes only if necessary
    [ "$(printf '%s\n%s\n' "$_suf" "$tpt_current_vers_suffix" |
        LC_COLLATE=C sort | head -n 1)" = "$_suf" ] && {
        cache_add_ok_vers "$_v_comp"
        return 0
    }
    # If none of the above conditions are met, the version is insufficient
    cache_add_bad_vers "$_v_comp"
    return 1
}

tpt_retrieve_running_tmux_vers() {
    #
    # If the variables defining the currently used tmux version needs to
    # be accessed before the first call to tmux_vers_ok this can be called.
    #
    log_it "tpt_retrieve_running_tmux_vers()"
    tpt_current_vers="$($TMUX_BIN -V | cut -d' ' -f2)"
    tpt_current_vers_i="$(tpt_digits_from_string "$tpt_current_vers")"
    tpt_current_vers_suffix="$(tpt_tmux_vers_suffix "$tpt_current_vers")"
}

tpt_digits_from_string() {
    # Extracts all numeric digits from a string, ignoring other characters.
    # Example inputs and outputs:
    #   "tmux 1.9" => "19"
    #   "1.9a"     => "19"
    log_it "><> tpt_digits_from_string($1)"
    # the first sed removes -rc suffixes, to avoid anny numerical rc like -rc1 from
    # being included in the int extraction
    _i="$(echo "$1" | sed 's/-rc[0-9]*//' | tr -cd '0-9')" # Use 'tr' to keep only digits
    echo "$_i"
}

tpt_tmux_vers_suffix() {
    # Extracts any alphabetic suffix from the end of a version string.
    # If no suffix exists, returns an empty string.
    # Example inputs and outputs:
    #   "3.2"  => ""
    #   "3.2a" => "a"
    log_it "><> tpt_tmux_vers_suffix($1)"
    echo "$1" | sed 's/.*[0-9]\([a-zA-Z]*\)$/\1/'
}

#===============================================================
#
#   Main
#
#===============================================================

plugin_name="tmux-menus"

#
#  Setting a cfg_log_file here will ignore the tmux setting @menus_log_file
#  This is mostly for debugging early stuff before the settings have
#  been processed. Should normally be commented out!
#
cfg_log_file="$HOME/tmp/${plugin_name}-dbg.log"

#
#  If set to "1" log will happen to stderr if script is run in an interactive
#  shell, so this will not mess it up if the plugin is initiated or run by tmux
#
log_interactive_to_stderr="1"

log_it "logging to stderr"

if [ -z "$D_TM_BASE_PATH" ]; then
    # helpers not yet sourced, so error_msg() not yet available
    msg="$plugin_name ERROR: $0 - D_TM_BASE_PATH must be set!"
    (
        echo
        echo "$msg"
        echo
    )
    $TMUX_BIN display-message "$msg"
    exit 1
fi

# if any condition requiring the full kit happens, do the sourcing and set
# this to true, to indicate everything is available
all_helpers_sourced=false

cfg_alt_menu_handler=""

# minimal support variables
d_cache="$D_TM_BASE_PATH"/cache
f_cache_params="$d_cache"/plugin_params

d_tmp="${TMPDIR:-/tmp}"
d_tmp="${d_tmp%/}" # Removes a trailing slash if present - sometimes set in TMPDIR...
f_no_cache_hint="$d_tmp"/no-cache-hint

# shellcheck disable=SC2154
if [ -f "$f_no_cache_hint" ]; then
    # ensure no caching until the settings has been read
    cfg_use_cache=false
else
    # Assume cache can be used, if this is not the case, this should be harmless
    # since when no cache is detected tmux options will be read and true state
    # for using cache will be detected
    cfg_use_cache=true
fi
log_it "><> scripts/helpers.sh - completed"
