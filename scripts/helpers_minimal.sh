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
    # will print to stderr if this is run interactively
    if [ -t 0 ]; then
        echo "$1" >/dev/stderr
        return 0
    else
        return 1
    fi
}

log_it() {
    [ "$TMUX_MENUS_LOGGING_MINIMAL" = "1" ] && return
    log_it_always "$1"
}

log_it_always() {
    # Call this directly for things that should be logged even when
    # TMUX_MENUS_LOGGING_MINIMAL is 1
    _msg="$1"

    [ "$log_interactive_to_stderr" = "1" ] && {
        # log to stderr if in interactive mode
        # printf "[%s] log: %s\n" "$(date '+%H:%M:%S')" "$_msg" >/dev/stderr
        print_stderr "log: $_msg" && return
        # continue if not an interactive session and use logfile
    }

    [ -n "$cfg_log_file" ] && {
        # log to file
        printf "[%s] %s\n" "$(date '+%H:%M:%S')" "$_msg" >>"$cfg_log_file"
    }
}

error_msg_safe() {
    #  Used when potentially called without having sourced everything
    $all_helpers_sourced || source_all_helpers "error_msg_safe($*)"
    error_msg "$1" "$2"
}

source_all_helpers() {
    # log_it "source_all_helpers() - $1"
    $all_helpers_sourced && {
        error_msg_safe "source_all_helpers() called when it was already done"
    }
    all_helpers_sourced=true # set it early to avoid recursion

    # shellcheck source=scripts/utils/helpers_full.sh
    . "$D_TM_BASE_PATH"/scripts/utils/helpers_full.sh || {
        error_msg_safe "Failed to source: scripts/utils/helpers_full.sh"
    }
}

relative_path() {
    # remove D_TM_BASE_PATH prefix
    # log_it "helpers:relative_path($1)"
    printf '%s\n' "${1#"$D_TM_BASE_PATH"/}"
}

select_menu_handler() {
    #
    # If an older version is used, or TMUX_MENUS_HANDLER is 1/2
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
    elif [ "$TMUX_MENUS_HANDLER" = 1 ]; then
        _cmd=whiptail
        if command -v "$_cmd" >/dev/null; then
            cfg_alt_menu_handler="$_cmd"
        else
            error_msg_safe "$_cmd not available, plugin aborted"
        fi
        cfg_use_whiptail=true
        log_it "NOTICE: $_cmd is selected due to TMUX_MENUS_HANDLER=1"
    elif [ "$TMUX_MENUS_HANDLER" = 2 ]; then
        _cmd=dialog
        if command -v "$_cmd" >/dev/null; then
            cfg_alt_menu_handler="$_cmd"
        else
            error_msg_safe "$_cmd not available, plugin aborted"
        fi
        cfg_use_whiptail=true
        log_it "NOTICE: $_cmd is selected due to TMUX_MENUS_HANDLER=2"
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

source_cached_params() {
    # log_it "source_cached_params()"
    result_sourcing=0

    [ "$log_file_forced" = 1 ] && orig_log_file="$cfg_log_file"

    if [ -f "$f_cache_params" ]; then
        # shellcheck disable=SC1090
        . "$f_cache_params" || result_sourcing=1
    else
        log_it "source_cached_params() - not found: $f_cache_params"
        result_sourcing=1
    fi

    [ "$log_file_forced" = 1 ] && {
        cfg_log_file="$orig_log_file"
        unset orig_log_file
        # log_it "restored cfg_log_file"
    }
    return "$result_sourcing"
}

get_config() {
    #
    #  The plugin init .tmux script should NOT depend on this!
    #  This is used by everything else sourcing helpers_minimal.sh, then trusting
    #  that the param cache is valid if found
    #
    # log_it "get_config()"

    if [ -f "$f_no_cache_hint" ]; then
        $all_helpers_sourced || source_all_helpers "get_config() - not using cache"
        tmux_get_plugin_options
        check_speed_cutoff 1
        # t_minimal_display_time=0.5 # since speed is unknown, use a concervative value
    elif [ -f "$f_cache_params" ]; then
        # log_it " get_config() - sourcing: $f_cache_params"

        if source_cached_params; then
            cache_params_retrieved=1
        else
            log_it "WARNING: get_config() failed to source: $f_cache_params, doing manual param read"
            $all_helpers_sourced || {
                source_all_helpers "get_config() - failed to source cached params"
            }
            get_config_read_save_if_uncached
        fi
        return 0
    else
        log_it "WARNING: no f_no_cache_hint and no f_cache_params!"
        $all_helpers_sourced || source_all_helpers "get_config() - no cache found"
        get_config_read_save_if_uncached
    fi
}

get_d_current_script() {
    error_msg_safe "Call to get_d_current_script($1)"
}

#---------------------------------------------------------------
#
#   get a time stamp
#
#---------------------------------------------------------------

select_safe_now_method() {
    # Select and save the time method for future use.
    [ -n "$selected_get_time_mthd" ] && {
        error_msg_safe "Recursive call to: select_safe_now_method"
    }

    if [ -d /proc ] && [ -f /proc/version ]; then
        selected_get_time_mthd="date" # Linux with sub-second precision
    elif [ "$(uname)" = "Linux" ]; then
        selected_get_time_mthd="date" # Termux or other Linux variations
    elif command -v gdate >/dev/null; then
        selected_get_time_mthd="gdate" # macOS, using GNU date if available
    elif command -v perl >/dev/null; then
        selected_get_time_mthd="perl" # Use Perl if date is not available
    else
        selected_get_time_mthd="date" # Fallback
    fi
}

safe_now() {
    #
    #  Sets t_now and if variable provided as param sets this variable
    #
    varname="$1"
    # [ -z "$varname" ] && error_msg_safe "safe_now() - no param"

    # log_it "safe_now($varname) mthd: [$selected_get_time_mthd]"
    case "$selected_get_time_mthd" in
    date) t_now="$(date +%s.%N)" ;;
    gdate) t_now="$(gdate +%s.%N)" ;;
    perl) t_now="$(perl -MTime::HiRes=time -E '$t = time; printf "%.9f\n", $t')" ;;
    *)
        select_safe_now_method

        # to prevent infinite recursion, eunsure a valid timing method is now selected
        case "$selected_get_time_mthd" in
        date | gdate | perl) ;;
        *) error_msg_safe "safe_now($varname) - failed to select a timing method" ;;
        esac

        safe_now "$varname"
        return
        ;;
    esac
    [ -n "$varname" ] && {
        # if variable name provided set it to t_now
        eval "$varname=\$t_now"
    }
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
    if [ -z "$current_tmux_vers" ] || [ -z "$current_tmux_vers_i" ]; then
        tpt_retrieve_running_tmux_vers
    fi

    # Use cache if available and enabled
    $cfg_use_cache && {
        if [ -z "$cached_ok_tmux_versions" ] && [ -f "$f_cache_known_tmux_vers" ]; then
            # Source known versions only if not already cached
            # shellcheck source=/dev/null
            . "$f_cache_known_tmux_vers" || {
                log_it "WARNING: Failed to source: f_cache_known_tmux_vers"
                cached_ok_tmux_versions=" " # Mark as failure to avoid further attempts
                cached_bad_tmux_versions=" "
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
    }

    # If helpers aren't sourced yet, source them before continuing the version check
    $all_helpers_sourced || {
        # tmux_vers_check might be called as the other helpers are sourced, so
        # ensure that the original check is retained
        _preserve_check_version="$_v_comp"
        source_all_helpers "tmux_vers_check($_v_comp) - non-cached version"
        _v_comp="$_preserve_check_version"
    }

    # Perform the actual version comparison check
    tmux_vers_check_do_compare "$_v_comp"
}

tpt_retrieve_running_tmux_vers() {
    #
    # If the variables defining the currently used tmux version needs to
    # be accessed before the first call to tmux_vers_ok this can be called.
    #
    # log_it "tpt_retrieve_running_tmux_vers()"
    current_tmux_vers="$($TMUX_BIN -V | cut -d' ' -f2)"
    # log_it "  current_tmux_vers [$current_tmux_vers]"
    tpt_digits_from_string current_tmux_vers_i "$current_tmux_vers"
    tpt_tmux_vers_suffix current_tmux_vers_suffix "$current_tmux_vers"
}

tpt_digits_from_string() {
    # Extracts all numeric digits from a string, ignoring other characters.
    # Example inputs and outputs:
    #   "tmux 1.9" => "19"
    #   "1.9a"     => "19"
    varname="$1"

    # Ensure arguments are present
    [ -z "$varname" ] && error_msg_safe "tpt_digits_from_string() - no variable name!"
    [ -z "$2" ] && error_msg_safe "tpt_digits_from_string() - no param!"

    # Remove "-rc" suffix and extract digits using parameter expansion
    _i=$(echo "$2" | tr -cd '0-9') # Keep only digits

    # Check if result is empty after digit extraction
    [ -z "$_i" ] && error_msg_safe "tpt_digits_from_string() - result empty"

    # Assign result to the variable
    eval "$varname=\$_i"
}

tpt_tmux_vers_suffix() {
    # Extracts any alphabetic suffix from the end of a version string.
    # If no suffix exists, returns an empty string.
    varname="$1"
    vers="$2"

    # Remove all leading digits and dots, leaving only the suffix
    _s="${vers##*([0-9.])}"

    # Assign result to the variable name
    eval "$varname=\"\$_s\""
}

#===============================================================
#
#   Main
#
#===============================================================

[ -z "$TMUX_BIN" ] && TMUX_BIN="tmux"
plugin_name="tmux-menus"

# will be 1 when limited env is ready, 2 when full env is ready
env_initialized=0

#
#  Setting log_file_forced here will ignore
#  the tmux setting @menus_log_file
#  This is mostly for debugging early stuff before the settings have
#  been processed. Should normally be commented out!
#  If this is set, cfg_log_file must also be defined since it won't be read from tmux.
#
# log_file_forced="1"
# cfg_log_file="$HOME/tmp/${plugin_name}-dbg.log"

#
#  If set to "1" log will happen to stderr if script is run in an interactive
#  shell, so this will not mess it up if the plugin is initiated or run by tmux
#  If log can't happen to stderr, it will go to cfg_log_file if it is defined
#
# log_interactive_to_stderr=1

[ -z "$D_TM_BASE_PATH" ] && {
    # helpers not yet sourced, so error_msg() not yet available
    msg="$plugin_name ERROR: $0 - D_TM_BASE_PATH must be set!"
    print_stderr "$msg"
    $TMUX_BIN display-message "$msg"
    exit 1
}

# Set this as early as possible to be able to calculate the entire menu processing time
safe_now t_script_start

min_tmux_vers="1.8"
cfg_use_whiptail=false
plugin_options_have_been_read=false # only need to read param once
# for performance only a minimum of support features are in this file
# as long as cache is used, it is sufficient, if extra features are needed
# a call to source_all_helpers will be done, this ensures it only happens once
all_helpers_sourced=false

case "$TMUX_MENUS_PROFILING" in
"1")
    case "$profiling_sourced" in
    "1") ;;
    *)
        # Here it is sourced  after D_TM_BASE_PATH is verified
        # if the intent is to start timing the earliest stages of other scripts
        # copy the below code using absolute paths
        # shellcheck source=scripts/utils/dbg_profiling.sh
        . "$D_TM_BASE_PATH"/scripts/utils/dbg_profiling.sh
        ;;
    esac
    ;;
*)
    # profiling calls should not be left in the code base long term, this
    # is primarily intended to capture them when profiling is temporarily disabled
    # profiling_display() {
    #     :
    # }
    ;;
esac

# minimal support variables

d_tmp="${TMPDIR:-/tmp}"
d_tmp="${d_tmp%/}" # Removes a trailing slash if present - sometimes set in TMPDIR...
f_no_cache_hint="$d_tmp"/tmux-menus-no-cache-hint

d_scripts="$D_TM_BASE_PATH"/scripts
d_items="$D_TM_BASE_PATH"/items
d_cache="$D_TM_BASE_PATH"/cache
f_cache_known_tmux_vers="$d_cache"/known_tmux_versions
f_cache_params="$d_cache"/plugin_params

d_basic_current_script=${0%/*} # quick vers, won't expand rel dirs or soft links
bn_current_script=${0##*/}     # same but faster than "$(basename "$0")"
bn_current_script_no_ext=${bn_current_script%.*}

wt_pasting="@tmp_menus_wt_paste_in_progress" # only used by whiptail

#
#  Convert script name to full actual path notation the path is used
#  for caching, so save it to a variable as well
#

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

if ! tmux_vers_check "$min_tmux_vers"; then
    # @variables are not usable prior to 1.8
    error_msg "need at least tmux $min_tmux_vers to work!"
fi

[ "$env_initialized" -eq 0 ] && env_initialized=1 # basic init done

# log_it "><> scripts/helpers_minimal.sh - completed [$0]"
