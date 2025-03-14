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

print_stderr() {
    if [ -t 0 ]; then
        echo "$1" >/dev/stderr
        return 0
    else
        return 1
    fi
}

log_it() {
    #  early abort if no logging, should not be needed, but might improve
    #  performance?
    [ "$TMUX_MENUS_FORCE_SILENT" = "3" ] && return

    _msg="$1"
    _type="$2"
    [ "$log_interactive_to_stderr" = "1" ] && {
        # log to stderr if in interactive mode
        # printf "[%s] log: %s\n" "$(date '+%H:%M:%S')" "$_msg" >/dev/stderr
        print_stderr "[$(date '+%H:%M:%S')] log: $_msg" && return
        # continue if not an interactive session and use logfile
    }

    [ -n "$cfg_log_file" ] && {
        # log to file
        if [ "$_type" = "profiling" ]; then
            printf "[p] %s\n" "$_msg" >>"$cfg_log_file"
        else
            printf "[%s] %s\n" "$(date '+%H:%M:%S')" "$_msg" >>"$cfg_log_file"
        fi
    }
}

error_msg_safe() {
    #  Used when potentially called without having sourced everything
    $all_helpers_sourced || source_all_helpers "error_msg_safe($*)"
    error_msg "$@"
}

source_all_helpers() {
    log_it "source_all_helpers() - $1"
    # profiling_display "[helpers] ----->  source_all_helpers [$0] $1"
    $all_helpers_sourced && {
        error_msg_safe "source_all_helpers() called when it was already done"
    }
    all_helpers_sourced=true # set it early to avoid recursion

    # shellcheck source=scripts/utils/helpers-full.sh
    . "$D_TM_BASE_PATH"/scripts/utils/helpers-full.sh
    # profiling_display "[helpers] <-----  source_all_helpers() - done"
}

relative_path() {
    # remove D_TM_BASE_PATH prefix
    # log_it "helpers:relative_path($1)"
    printf '%s\n' "${1#"$D_TM_BASE_PATH"/}"
}

select_menu_handler() {
    #
    # If an older version is used, or TMUX_MENU_HANDLER is 1/2
    # set cfg_use_whiptail true
    #
    # log_it "select_menu_handler()"
    if ! tmux_vers_check 3.0; then
        if command -v whiptail >/dev/null; then
            cfg_alt_menu_handler=whiptail
            log_it "NOTICE: tmux below 3.0 - using: whiptail"
        elif command -v dialog >/dev/null; then
            cfg_alt_menu_handler=dialog
            log_it "NOTICE: tmux below 3.0 - using: dialog"
        else
            error_msg_safe "Neither whiptail or dialog found, plugin aborted"
        fi
        cfg_use_whiptail=true
    elif [ "$TMUX_MENU_HANDLER" = 1 ]; then
        _cmd=whiptail
        if command -v "$_cmd" >/dev/null; then
            cfg_alt_menu_handler="$_cmd"
        else
            error_msg_safe "$_cmd not available, plugin aborted"
        fi
        cfg_use_whiptail=true
        log_it "NOTICE: $_cmd is selected due to TMUX_MENU_HANDLER=1"
    elif [ "$TMUX_MENU_HANDLER" = 2 ]; then
        _cmd=dialog
        if command -v "$_cmd" >/dev/null; then
            cfg_alt_menu_handler="$_cmd"
        else
            error_msg_safe "$_cmd not available, plugin aborted"
        fi
        cfg_use_whiptail=true
        log_it "NOTICE: $_cmd is selected due to TMUX_MENU_HANDLER=2"
    else
        cfg_use_whiptail=false
        cfg_alt_menu_handler=""
    fi
    # log_it "  <-- select_menu_handler() - done"
}

#---------------------------------------------------------------
#
#   get configuration
#
#---------------------------------------------------------------

get_config_read_save_if_uncached() {
    # reads config, and if allowed saves it to cache
    # profiling_display "[helpers] get_config_read_save_if_uncached()"

    $all_helpers_sourced || source_all_helpers "get_config_read_save_if_uncached()"
    cache_config_get_save || {
        # cache couldn't be saved, indicate cache not available
        log_it "  <-- get_config_read_save_if_uncached() - unable to save cache params"
        cfg_use_cache=false
    }
}

get_config() {
    #
    #  The plugin init .tmux script should NOT depend on this!
    #  This is used by everything else sourcing helpers.sh, then trusting
    #  that the param cache is valid if found
    #
    # log_it "get_config()"
    # profiling_display "[helpers] get_config()"

    if [ -f "$f_no_cache_hint" ]; then
        log_it "Will call it due to f_no_cache_hint"
        get_config_read_save_if_uncached
    elif [ -f "$f_cache_params" ]; then
        # shellcheck disable=SC1090
        if . "$f_cache_params"; then
            cache_params_retrieved=1
        else
            log_it "WARNING: failed to source: $f_cache_params, doing manual param read"
            get_config_read_save_if_uncached
        fi
        return 0
    else
        log_it "WARNING: no f_no_cache_hint and no f_cache_params!"
        get_config_read_save_if_uncached
    fi
}

#---------------------------------------------------------------
#
#   get a time stamp
#
#---------------------------------------------------------------

select_safe_now_method() {
    # figure out what method to use and save the selection for future usage
    # log_it "select_safe_now_method()"
    [ -n "$selected_get_time_mthd" ] && {
        # if this is called when the method was selected something is wrong...
        error_msg_safe "recursive call to: select_safe_now_method()"
    }

    if [ -d /proc ] && [ -f /proc/version ]; then
        #  On Linux the native date supports sub second precision
        #  unless its the busybox date - only gives seconds...
        selected_get_time_mthd="date"
    elif [ "$(uname)" = "Linux" ]; then
        # Non-standard devices still being Linux, such as termux
        selected_get_time_mthd="date"
    elif [ -n "$(command -v gdate)" ]; then
        # The MacOS date doesn't support sub seconds, if gdate is available use it.
        selected_get_time_mthd="gdate"
    elif [ -n "$(command -v perl)" ]; then
        # Slower than gdate but still usable, built-in on MacOS
        selected_get_time_mthd="perl"
    else
        # Fallback
        selected_get_time_mthd="date"
    fi
    # log_it "[$0] Using  safe_now() timing method: $selected_get_time_mthd"
    safe_now
}

safe_now() {
    #
    #  Sets t_now
    #
    # log_it "safe_now() mthd: [$selected_get_time_mthd]"
    case "$selected_get_time_mthd" in
    date) t_now="$(date +%s.%N)" ;;
    gdate) t_now="$(gdate +%s.%N)" ;;
    perl) t_now="$(perl -MTime::HiRes=time -E '$t = time; printf "%.9f\n", $t')" ;;
    *) select_safe_now_method ;;
    esac
}

#---------------------------------------------------------------
#
#   tmux version related support functions
#
#---------------------------------------------------------------

tmux_vers_check() {
    _v_comp="$1" # Desired minimum version to check against
    # log_it "tmux_vers_check($_v_comp)"
    [ -z "$_v_comp" ] && error_msg_safe "tmux_vers_check() - no param!"

    # Retrieve and cache the current tmux version on the first call,
    # unless it has been read from the param cache
    if [ -z "$tpt_current_vers" ] || [ -z "$tpt_current_vers_i" ]; then
        tpt_retrieve_running_tmux_vers
    fi

    $cfg_use_cache && {
        [ -z "$cached_ok_tmux_versions" ] && [ -f "$f_cache_known_tmux_vers" ] && {
            #
            # get known good/bad versions if this hasn't been sourced yet
            #
            # shellcheck source=/dev/null
            . "$f_cache_known_tmux_vers" || {
                log_it "WARNING: Failed to source: f_cache_known_tmux_vers"
                # make them non empty to prevent further attempts to be sourced
                cached_ok_tmux_versions=" "
                cached_bad_tmux_versions=" "
            }
        }
        case " $cached_ok_tmux_versions " in
        *"$_v_comp "*) return 0 ;;
        *) ;;
        esac
        case "$cached_bad_tmux_versions" in
        *"$_v_comp "*) return 1 ;;
        *) ;;
        esac
    }

    $all_helpers_sourced || {
        # During sourcing, other version checks might be done, thus
        # preserve the current version being inspected
        _preserve_check_version="$_v_comp"
        source_all_helpers "tmux_vers_check($_v_comp) - non-cached version"
        _v_comp="$_preserve_check_version"
    }

    # posix inherits return code from last cmd
    tmux_vers_check_do_compare "$_v_comp"
}

tpt_retrieve_running_tmux_vers() {
    #
    # If the variables defining the currently used tmux version needs to
    # be accessed before the first call to tmux_vers_ok this can be called.
    #
    # log_it "tpt_retrieve_running_tmux_vers()"
    tpt_current_vers="$($TMUX_BIN -V | cut -d' ' -f2)"
    # log_it "  tpt_current_vers [$tpt_current_vers]"
    tpt_digits_from_string tpt_current_vers_i "$tpt_current_vers"
    # tpt_current_vers_suffix="$(tpt_tmux_vers_suffix "$tpt_current_vers")"
    tpt_tmux_vers_suffix tpt_current_vers_suffix "$tpt_current_vers"
}

tpt_digits_from_string() {
    # Extracts all numeric digits from a string, ignoring other characters.
    # Example inputs and outputs:
    #   "tmux 1.9" => "19"
    #   "1.9a"     => "19"
    varname="$1"
    # log_it "tpt_digits_from_string($varname,$2)"

    [ -z "$varname" ] && error_msg_safe "tpt_digits_from_string() - no variable name!"
    [ -z "$2" ] && error_msg_safe "tpt_digits_from_string() - no param!"

    # the first sed removes -rc suffixes, to avoid anny numerical rc like -rc1 from
    # being included in the int extraction
    # Use 'tr' to keep only digits
    _i="$(echo "$2" | sed 's/-rc[0-9]*//' | tr -cd '0-9')" || {
        error_msg_safe "tpt_digits_from_string() - Failed to extract digits"
    }
    [ -z "$_i" ] && error_msg_safe "tpt_digits_from_string() - result empty"
    eval "$varname=\$_i"
}

tpt_tmux_vers_suffix() {
    # Extracts any alphabetic suffix from the end of a version string.
    # If no suffix exists, returns an empty string.
    # Example inputs and outputs:
    #   "3.2"  => ""
    #   "3.2a" => "a"
    varname="$1"
    # log_it "tpt_tmux_vers_suffix($varname, $2)"
    _s="$(echo "$2" | sed 's/.*[0-9]\([a-zA-Z]*\)$/\1/')" || {
        error_msg_safe "tpt_tmux_vers_suffix() - Failed to extract suffix"
    }
    # log_it " <-- tpt_tmux_vers_suffix() - result [$_s]"
    eval "$varname=\$_s"
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
log_interactive_to_stderr=1

[ "$log_interactive_to_stderr" = "1" ] && {
    # TMUX_MENUS_FORCE_SILENT overrides and disables log_interactive_to_stderr
    case "$TMUX_MENUS_FORCE_SILENT" in
    1 | 2) log_interactive_to_stderr=0 ;;
    *) ;;
    esac
}

cfg_use_whiptail=false
plugin_options_have_been_read=false # only need to read param once
# for performance only a minimum of support features are in this file
# as long as cache is used, it is sufficient, if extra features are needed
# a call to source_all_helpers will be done, this ensures it only happens once
all_helpers_sourced=false

[ -z "$TMUX_BIN" ] && TMUX_BIN="tmux"

if [ -z "$D_TM_BASE_PATH" ]; then
    # helpers not yet sourced, so error_msg_safe() not yet available
    msg="$plugin_name ERROR: $0 - D_TM_BASE_PATH must be set!"
    (
        echo
        echo "$msg"
        echo
    )
    $TMUX_BIN display-message "$msg"
    exit 1
fi

if [ "$MENUS_PROFILING" != "1" ]; then
    # profiling calls should not be left in the code base long term, this
    # is primarily intended to capture them when profiling is temporarily disabled

    profiling_display() {
        true
    }
elif [ "$MENUS_PROFILING" = "1" ] && [ "$profiling_sourced" != "1" ]; then
    # Here it is sourced  after D_TM_BASE_PATH is verified
    # if the intent is to start timing the earliest stages of other scripts
    # copy the below code using absolute paths
    # shellcheck source=scripts/utils/dbg_profiling.sh
    . "$D_TM_BASE_PATH"/scripts/utils/dbg_profiling.sh
fi

# minimal support variables

d_tmp="${TMPDIR:-/tmp}"
d_tmp="${d_tmp%/}" # Removes a trailing slash if present - sometimes set in TMPDIR...
f_no_cache_hint="$d_tmp"/no-cache-hint

d_scripts="$D_TM_BASE_PATH"/scripts
d_items="$D_TM_BASE_PATH"/items
d_cache="$D_TM_BASE_PATH"/cache
f_cache_known_tmux_vers="$d_cache"/known_tmux_versions
f_cache_params="$d_cache"/plugin_params

#
#  Convert script name to full actual path notation the path is used
#  for caching, so save it to a variable as well
#

# shellcheck disable=SC2164
d_current_script="$(
    cd "$(dirname "$0")"
    pwd
)"
current_script=${0##*/}
f_current_script="$d_current_script/$current_script"

if [ -d "$d_cache" ]; then
    cfg_use_cache=true
else
    # Assume cache is disabled, if this is not the case, this should be harmless
    # since when tmux options will be read it will be used if enabled
    cfg_use_cache=false
fi

[ "$initialize_plugin" = "1" ] && {
    return
}

# [ "$1" != "quick" ] && {
#     # for cache optimized sourcings of this set it to quick, to avoid the
#     #  entire help environment from being sourced
#     $all_helpers_sourced || source_all_helpers "helpers - main"
# }

get_config

min_tmux_vers="1.8"
if ! tmux_vers_check "$min_tmux_vers"; then
    # @variables are not usable prior to 1.8
    error_msg "need at least tmux $min_tmux_vers to work!"
fi

# log_it "><> scripts/helpers.sh - completed"
