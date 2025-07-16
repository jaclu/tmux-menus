#!/bin/sh
# Always sourced file - Fake bang path to help editors
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
    # will print to stderr if this is run interactively
    if [ -t 0 ]; then
        echo "$1" >/dev/stderr
        return 0
    else
        return 1
    fi
}

log_it() {
    # shellcheck disable=SC2154 # TMUX_MENUS_LOGGING_MINIMAL is an env variable
    [ "$TMUX_MENUS_LOGGING_MINIMAL" = "1" ] && return
    log_it_minimal "$1"
}

log_it_minimal() {
    # Call this directly for things that should be logged even when
    # TMUX_MENUS_LOGGING_MINIMAL is 1
    # if TMUX_MENUS_LOGGING_MINIMAL=2 logging is completely disabled
    [ "$TMUX_MENUS_LOGGING_MINIMAL" = "2" ] && return
    _msg="[$$] $1"

    [ "$log_interactive_to_stderr" = "1" ] && {
        # log to stderr if in interactive mode
        # printf "[%s] log: %s\n" "$(date '+%H:%M:%S')" "$_msg" >/dev/stderr
        print_stderr "log: $_msg" && return
        # continue if not an interactive session and use logfile
    }

    if [ -n "$cfg_log_file" ]; then
        # log to file
        printf "[%s] %s\n" "$(date '+%H:%M:%S')" "$_msg" >>"$cfg_log_file"
    # else
    #     # if no log file has been defined, try to use stderr
    #     # should only be used for debugging
    #     print_stderr "log: $_msg" && return
    fi
}

error_msg_safe() {
    #  Used when potentially called without having sourced everything
    msg="$1"
    exit_code="$2"
    $all_helpers_sourced || source_all_helpers "error_msg_safe()"
    error_msg "$msg" "$exit_code"
}

source_all_helpers() {
    #
    #  Sources the full helper environment, if not already loaded.
    #
    #  Initially, only helpers_minimal.sh is loaded for performance. It includes:
    #   - log_it / log_it_minimal
    #   - tmux_vers_check
    #   - safe_now & time_span (used by dialog_handling to log render speed)
    #   - error_msg_safe (safe to call before full sourcing)
    #
    #  Use this to load all helpers when needed, ensuring it's only done once:
    #    $all_helpers_sourced || source_all_helpers "caller description"
    #

    # log_it "source_all_helpers() - $1"
    $all_helpers_sourced && {
        error_msg_safe "source_all_helpers() called when it was already done - $1"
    }
    all_helpers_sourced=true # set it early to avoid recursion

    # shellcheck source=scripts/utils/helpers_full.sh
    . "$D_TM_BASE_PATH"/scripts/utils/helpers_full.sh || {
        error_msg_safe "Failed to source: scripts/utils/helpers_full.sh"
    }
}

relative_path() { # Needed here due to: prepare_menu() - set_menu_env_variables()
    # remove D_TM_BASE_PATH prefix
    # log_it "relative_path($1) - removing prefix: $D_TM_BASE_PATH"
    printf '%s\n' "${1#"$D_TM_BASE_PATH"/}"
}

validate_varname() { # local usage tpt_digits_from_string() tpt_tmux_vers_suffix()
    case "$1" in
    [a-zA-Z_][a-zA-Z0-9_]*) return 0 ;;
    *) error_msg_safe "$2 Invalid variable name: $1" ;;
    esac
}

#---------------------------------------------------------------
#
#   get configuration
#
#---------------------------------------------------------------

source_cached_params() {
    # This is just reading, so ok to do even if cache is disabled
    # log_it "source_cached_params()"

    if [ -f "$f_cache_params" ]; then
        [ "$log_file_forced" = 1 ] && {
            # if log file is forced, save setting, in order to ignore cached config
            orig_log_file="$cfg_log_file"
        }

        # shellcheck source=/dev/null # not always present
        . "$f_cache_params" || {
            [ "$log_file_forced" = 1 ] && cfg_log_file="$orig_log_file"
            log_it "source_cached_params() - Failed to source: $f_cache_params"
            return 1
        }

        [ "$log_file_forced" = 1 ] && {
            # use the forced log_file, ignoring any potential cached entry
            cfg_log_file="$orig_log_file"
            unset orig_log_file
            # log_it "restored cfg_log_file"
        }
    else
        # log_it "source_cached_params() - not found: $f_cache_params"
        return 1
    fi

    return 0
}

get_config() { # local usage during sourcing
    #
    #  The plugin init .tmux script should NOT depend on this!
    #  This is used by everything else sourcing helpers_minimal.sh, then trusting
    #  that the param cache is valid if found
    #
    # log_it "get_config() - $rn_current_script"
    replace_config=false
    if [ -f "$f_no_cache_hint" ]; then
        cfg_use_cache=false
        $all_helpers_sourced || {
            source_all_helpers "get_config() - no cache hint found"
        }
        tmux_get_plugin_options
        # ckoud node .16 jacmacm 0.32 jacpad 1.5  jacdroid 1.2
        check_speed_cutoff 0.6
    elif [ -f "$f_cache_params" ]; then
        source_cached_params || {
            replace_config=true
            _m="WARNING: get_config() failed to source: $f_cache_params,"
            _m="$_m calling config_setup"
            log_it "$_m"
        }
    else
        replace_config=true
    fi

    if $replace_config; then
        $all_helpers_sourced || {
            source_all_helpers "get_config() - failed to source cached params"
        }
        config_setup
    else
        handle_env_variables
    fi
}

#---------------------------------------------------------------
#
#   env variables
#
#---------------------------------------------------------------

menu_handler_cache_missmatch() {
    # Report a mismatch between TMUX_MENUS_HANDLER and current cache

    # shellcheck disable=SC2154 # TMUX_MENUS_HANDLER is an env variable
    msg="TMUX_MENUS_HANDLER=$TMUX_MENUS_HANDLER"
    [ -n "$1" ] && msg="$msg ($1)"
    msg="$msg does not match current cache:\n\n"
    msg="$msg    cfg_use_whiptail=$cfg_use_whiptail\n"
    msg="$msg    cfg_alt_menu_handler=$cfg_alt_menu_handler"
    error_msg_safe "$msg"
}

verify_menu_handler_override_valid() {
    # Ensure manual override of menu handler is not a mismatch vs current cache

    # shellcheck disable=SC2154 # defined in plugin_init.sh
    [ "$initialize_plugin" = "1" ] && return # not relevant during plugin init
    # log_it "verify_menu_handler_override_valid($requested_handler)"
    requested_handler="$1"
    ! $cfg_use_cache && return # irrelevant check when not using cache

    if ! $cfg_use_whiptail || [ "$cfg_alt_menu_handler" != "$requested_handler" ]; then
        menu_handler_cache_missmatch "$requested_handler"
    fi
}

env_variable_menus_handler() {
    # handles TMUX_MENUS_HANDLER
    #
    # Provides: b_whiptail_forced
    #
    # log_it "env_variable_menus_handler()"

    case "$TMUX_MENUS_HANDLER" in
    0) $cfg_use_whiptail && verify_menu_handler_override_valid "tmux display-menu" ;;
    1)
        _cmd=whiptail
        verify_menu_handler_override_valid "$_cmd"
        if command -v "$_cmd" >/dev/null; then
            cfg_alt_menu_handler="$_cmd"
        else
            error_msg_safe "$_cmd not available, plugin aborted"
        fi
        cfg_use_whiptail=true
        [ "$initialize_plugin" = "1" ] && {
            log_it "NOTICE: $_cmd is selected due to TMUX_MENUS_HANDLER=1"
        }
        b_whiptail_forced=true
        ;;
    2)
        _cmd=dialog
        verify_menu_handler_override_valid "$_cmd"
        if command -v "$_cmd" >/dev/null; then
            cfg_alt_menu_handler="$_cmd"
        else
            error_msg_safe "$_cmd not available, plugin aborted"
        fi
        cfg_use_whiptail=true
        [ "$initialize_plugin" = "1" ] && {
            log_it "NOTICE: $_cmd is selected due to TMUX_MENUS_HANDLER=2"
        }
        b_whiptail_forced=true
        ;;
    *)
        msg="TMUX_MENUS_HANDLER=$TMUX_MENUS_HANDLER - valid options: 0 1 2"
        error_msg_safe "$msg"
        ;;
    esac

    $b_whiptail_forced && {
        $all_helpers_sourced || {
            source_all_helpers "get_config() needs use_whiptail_env"
        }
        use_whiptail_env
    }
}

handle_env_variables() { # local usage by get_config()
    # Check env variables and apply relevant env checks & config overrides
    #
    # Provides: b_whiptail_forced
    #
    # log_it "handle_env_variables()"

    # TMUX_MENUS_LOGGING_MINIMAL - is handled directly by log_it() - no config needed
    # TMUX_MENUS_NO_DISPLAY -  is handled directly - no config needed
    # TMUX_MENUS_PROFILING - is handled directly - no config needed
    [ -n "$TMUX_MENUS_HANDLER" ] && env_variable_menus_handler

}

#---------------------------------------------------------------
#
#   get a time stamp
#
#---------------------------------------------------------------

select_safe_now_method() { # local usage by safe_now()
    #
    # Select and save the time method for future use.
    #
    # Provides: selected_safe_now_mthd
    #
    [ -n "$selected_safe_now_mthd" ] && {
        error_msg_safe "Recursive call to: select_safe_now_method"
    }
    # log_it "select_safe_now_method()"

    if [ -d /proc ] && [ -f /proc/version ]; then
        selected_safe_now_mthd="date" # Linux with sub-second precision
    elif [ "$(uname)" = "Linux" ]; then
        selected_safe_now_mthd="date" # Termux or other Linux variations
    elif command -v gdate >/dev/null; then
        selected_safe_now_mthd="gdate" # macOS, using GNU date if available
    elif command -v perl >/dev/null; then
        selected_safe_now_mthd="perl" # Use Perl if date is not available
    else
        selected_safe_now_mthd="date" # Fallback
    fi
}

safe_now() {
    #
    #  Sets t_now to the current timestamp. If a variable name is given,
    #  it will be assigned the same value directly (no subshell).
    #
    #  Provides: t_now
    #
    varname="$1"
    # validate_varname "$varname" "safe_now()()" # disabled for performance

    # [ -n "$selected_safe_now_mthd" ] && {
    #     # first call will have no method defined, so this will recurse once it is
    #     # set
    #     log_it "safe_now($varname) mthd: [$selected_safe_now_mthd]"
    # }

    case "$selected_safe_now_mthd" in
    date) t_now="$(date +%s.%N)" ;;
    gdate) t_now="$(gdate +%s.%N)" ;;
    perl) t_now="$(perl -MTime::HiRes=time -E '$t = time; printf "%.9f\n", $t')" ;;
    *)
        select_safe_now_method

        # to prevent infinite recursion, eunsure a valid timing method is now selected
        case "$selected_safe_now_mthd" in
        date | gdate | perl) ;;
        *) error_msg_safe "safe_now($varname) - failed to select a timing method" ;;
        esac

        safe_now "$varname"
        return
        ;;
    esac
    [ -n "$varname" ] && {
        # if variable name provided set it to t_now
        eval "$varname=\"\$t_now\""
    }
}

time_span() { # display_menu() / check_speed_cutoff()
    #
    # Calculates a time span compared to param 1
    #
    # Provides: t_time_span
    #
    _t_start="$1"

    safe_now
    t_time_span="$(echo "$t_now - $_t_start" | bc)"
}

#---------------------------------------------------------------
#
#   tmux version related support functions
#
#---------------------------------------------------------------

tmux_vers_check() { # local usage when checking $min_tmux_vers
    _v_comp="$1"    # Desired minimum version to check against
    # log_it "tmux_vers_check($_v_comp)"
    [ -z "$_v_comp" ] && error_msg_safe "tmux_vers_check() - no param!"

    # Retrieve and cache the current tmux version on the first call,
    # unless it has been read from the param cache
    if [ -z "$current_tmux_vers" ] || [ -z "$current_tmux_vers_i" ]; then
        tpt_retrieve_running_tmux_vers
    fi

    if [ -z "$cached_ok_tmux_versions" ] && [ -f "$f_cache_known_tmux_vers" ]; then
        # Reading it if existing is harmless even if cache is disabled
        # shellcheck source=/dev/null
        . "$f_cache_known_tmux_vers" || {
            log_it "WARNING: Failed to source: f_cache_known_tmux_vers"
            # Since the source failed, clear these in orde to ensure no bad
            # state was retrieved
            cached_ok_tmux_versions=""
            cached_bad_tmux_versions=""
        }
    fi

    # Check if the version is in the cached good or bad lists using case statements
    case " $cached_ok_tmux_versions " in
    *"$_v_comp "*) return 0 ;; # Version found in good list
    *) ;;
    esac
    case "$cached_bad_tmux_versions" in
    *"$_v_comp "*) return 1 ;; # Version found in bad list
    *) ;;
    esac

    # Once a menu has been processed once, all version references should already be
    # cached, so in the normal cached state this point will not be reached

    # If helpers aren't sourced yet, source them before continuing the version check
    $all_helpers_sourced || {
        # tmux_vers_check might be called as the other helpers are sourced, so
        # ensure that the original check is retained
        _preserve_check_version="$_v_comp"
        source_all_helpers "tmux_vers_check($_v_comp) - non-cached version"
        _v_comp="$_preserve_check_version"
    }

    # Perform the actual version comparison check, and then store it as a good/bad version
    tmux_vers_check_do_compare "$_v_comp"
}

tpt_retrieve_running_tmux_vers() { # local usage by tmux_vers_check()
    #
    # If the variables defining the currently used tmux version needs to
    # be accessed before the first call to tmux_vers_ok this can be called.
    # This will by nececity be called as config_setup() is processing, so unless
    # caching is disabled, this won't be called by menus directly.
    #
    # log_it "tpt_retrieve_running_tmux_vers()"
    current_tmux_vers="$($TMUX_BIN -V | cut -d' ' -f2)"
    # log_it "  current_tmux_vers [$current_tmux_vers]"
    tpt_digits_from_string current_tmux_vers_i "$current_tmux_vers"
    tpt_tmux_vers_suffix current_tmux_vers_suffix "$current_tmux_vers"
}

tpt_digits_from_string() { # local usage by tpt_retrieve_running_tmux_vers()
    # Extracts all numeric digits from a string, ignoring other characters.
    # Example inputs and outputs:
    #   "tmux 1.9" => "19"
    #   "1.9a"     => "19"
    #
    #  Assigning the supplied variable name instead of printing output in a subshell,
    #  for better performance
    #
    varname="$1"
    validate_varname "$varname" "tpt_digits_from_string()"

    # Ensure arguments are present
    [ -z "$varname" ] && error_msg_safe "tpt_digits_from_string() - no variable name!"
    [ -z "$2" ] && error_msg_safe "tpt_digits_from_string() - no param!"

    # Remove "-rc" suffix and extract digits using parameter expansion
    _i=$(echo "$2" | cut -d'-' -f1 | tr -cd '0-9') # Keep only digits

    # Check if result is empty after digit extraction
    [ -z "$_i" ] && error_msg_safe "tpt_digits_from_string() - result empty"

    # Assign result to the variable
    eval "$varname=\"\$_i\""
}

tpt_tmux_vers_suffix() { # local usage by tpt_retrieve_running_tmux_vers()
    # Extracts any alphabetic suffix from the end of a version string.
    # If no suffix exists, returns an empty string.
    #
    # Assigning the supplied variable name instead of printing output in a subshell,
    # for better performance
    varname="$1"
    vers="$2"
    validate_varname "$varname" "tpt_tmux_vers_suffix()"
    # Remove leading digits, dots, and dashes to isolate suffix
    _s=$(printf "%s" "$vers" | sed 's/^[0-9.-]*//')

    eval "$varname=\"\$_s\""
}

base_path_not_defined() {
    # Show error msg if D_TM_BASE_PATH is not defined
    # helpers not yet sourced, so TMUX_BIN & error_msg() not yet available
    msg="$plugin_name ERROR: $0 - D_TM_BASE_PATH must be set!"
    print_stderr "$msg"
    $TMUX_BIN display-message "$msg"
    exit 1
}

#===============================================================
#
#   Main
#
#===============================================================

[ -z "$TMUX_BIN" ] && TMUX_BIN="tmux"

env_initialized=0 # will be 1 when limited env is ready, 2 when full env is ready

plugin_name="tmux-menus"

#
# Defining a cfg_log_file here, allows tracing early startup, before the plugin
# defined log_file variable @menus_log_file have been read.
#
# At that point @menus_log_file will override this setting, unless log_file_forced
# is also used. If 1 it means that @menus_log_file will be ignored and whatever
# cfg_log_file is defined here remains. Be it a file or empty.
#
#  This should normally be commented out!
#
# cfg_log_file="$HOME/tmp/${plugin_name}-dbg.log"
# log_file_forced="1"

#
#  If set to 1 log will happen to stderr if script is run in an interactive
#  shell, so this will not mess it up if the plugin is initiated or run by tmux
#  If log can't happen to stderr, it will go to @menus_log_file if it is defined
#
log_interactive_to_stderr=0

min_tmux_vers=1.5 # oldest accepted tmux version

# for performance only a minimum of support features are in this file
# as long as cache is used, it is sufficient, if extra features are needed
# a call to source_all_helpers will be done, this ensures it only happens once
all_helpers_sourced=false

d_tmp="${TMPDIR:-/tmp}"
d_tmp="${d_tmp%/}" # Removes a trailing slash if present - sometimes set in TMPDIR...
f_no_cache_hint="$d_tmp"/tmux-menus-no-cache-hint

[ -z "$D_TM_BASE_PATH" ] && base_path_not_defined

d_scripts="$D_TM_BASE_PATH"/scripts
d_items="$D_TM_BASE_PATH"/items
d_cache="$D_TM_BASE_PATH"/cache
f_cache_known_tmux_vers="$d_cache"/known_tmux_versions
f_cache_params="$d_cache"/plugin_params

# Set this as early as possible to be able to calculate the entire menu processing time
safe_now t_script_start

# shellcheck disable=SC2034 # provided as env for other scripts
{
    # in order to only need one SC2034 group all variables under one shellcheck

    # Used if main menu cache should be purged, like if custom_items are detected
    # or found to be gone
    d_cache_main_menu="$d_cache"/items/main.sh

    # Used if main menu should be run
    f_main_menu="$d_items"/main.sh

    f_ext_dlg_trigger="$d_scripts/external_dialog_trigger.sh"

    bn_current_script=${0##*/} # same but faster than "$(basename "$0")"
    rn_current_script=$(relative_path "$0")
    # bn_current_script_no_ext=${bn_current_script%.*}
}

# --->  Only enable this if profiling is being used  <---
# shellcheck source=scripts/utils/dbg_profiling.sh
# [ "$profiling_sourced" != 1 ] && . "$D_TM_BASE_PATH"/scripts/utils/dbg_profiling.sh

[ "$initialize_plugin" != "1" ] && {
    # plugin_init will call config_setup directly, so should not call get_config
    get_config
}

if ! tmux_vers_check "$min_tmux_vers"; then
    # @variables are not usable prior to 1.8
    error_msg_safe "$plugin_name needs at least tmux $min_tmux_vers to work!"
fi

if [ -d "$d_cache" ]; then
    # For temp files etc that needs to be created even when caching is disabled
    # use d_safe_tmp_folder folder. This will prioritize the cach-folder, and use tmp
    # as fallback
    d_safe_tmp_folder="$d_cache"
else
    d_safe_tmp_folder="$d_tmp"
fi

# This allows 'Display Commands' even when cache is disabled
# shellcheck disable=SC2034 # provided as env for other scripts
f_cached_tmux_key_binds="$d_safe_tmp_folder"/tmux_key_binds

[ "$env_initialized" -eq 0 ] && env_initialized=1 # basic init done

# log_it "><> [$$] scripts/helpers_minimal.sh - completed [$0]"
