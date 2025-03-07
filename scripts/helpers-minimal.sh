#!/bin/sh
# Always sourced file - Fake bang path to help editors
# shellcheck disable=SC2034,SC2154

#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Minimal support functions, enough when caches is used and cache is available
#  All support functions will be sourced if needed, all to improve performance
#

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
    log_it "relative_path($1)" # with cache:

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
        # not using cache, read all cfg variables
        tmux_get_plugin_options
        dbg_t_update "[helpers] - tmux_get_plugin_options() done"

    elif ! cache_get_params; then
        # Re-generate cache params
        cache_update_param_cache
        dbg_t_update "[helpers] - cache_update_param_cache() done"
    fi
}



tmux_select_menu_handler() {
    # support old env variable, cam be deleted eventually 241220
    log_it "><> tmux_select_menu_handler()"
    [ -n "$FORCE_WHIPTAIL_MENUS" ] && TMUX_MENU_HANDLER="$FORCE_WHIPTAIL_MENUS"

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
            error_msg "Neither whiptail or dialog found, plugin aborted"
        fi
        cfg_use_whiptail=true
    elif [ "$TMUX_MENU_HANDLER" = 1 ]; then
        _cmd=whiptail
        if command -v "$_cmd" >/dev/null; then
            cfg_alt_menu_handler="$_cmd"
        else
            error_msg "$_cmd not available, plugin aborted"
        fi
        cfg_use_whiptail=true
        log_it "$_cmd is selected due to TMUX_MENU_HANDLER=1"
        unset _cmd
    elif [ "$TMUX_MENU_HANDLER" = 2 ]; then
        _cmd=dialog
        if command -v "$_cmd" >/dev/null; then
            cfg_alt_menu_handler="$_cmd"
        else
            error_msg "$_cmd not available, plugin aborted"
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
