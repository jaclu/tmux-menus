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
    # TMUX_MENUS_LOGGING_MINIMAL=1
    #   Calls to log_it are ignored, only calls to log_it_minimal take effect
    # TMUX_MENUS_LOGGING_MINIMAL=2
    #   log_it & log_it_minimal are skipped
    #
    [ "${TMUX_MENUS_LOGGING_MINIMAL:-0}" -gt 0 ] && return
    log_it_minimal "$1"
}

log_it_minimal() {
    # Call this directly for things that should be logged even when
    # TMUX_MENUS_LOGGING_MINIMAL is 1
    # if TMUX_MENUS_LOGGING_MINIMAL=2 logging is completely disabled
    [ "${TMUX_MENUS_LOGGING_MINIMAL:-0}" -gt 1 ] && return
    _msg="[$$] $1"

    [ "$log_interactive_to_stderr" = "1" ] && {
        # log to stderr if in interactive mode
        # printf "[%s] log: %s\n" "$(date '+%H:%M:%S')" "$_msg" >/dev/stderr
        print_stderr "log: $_msg" && return
        # continue if not an interactive session and use logfile if defined
    }

    if [ -n "$cfg_log_file" ]; then
        # log to file
        _lim_timestamp=$(date '+%H:%M:%S')
        printf '[%s] %s\n' "$_lim_timestamp" "$_msg" >>"$cfg_log_file"
    # else
    #     # if no log file has been defined, try to use stderr
    #     # should only be used for debugging
    #     print_stderr "log: $_msg" && return
    fi
}

error_msg() {
    #  Used when potentially called without having sourced everything
    msg="$1"
    exit_code="$2"
    ${b_all_helpers_sourced:-false} || source_all_helpers "error_msg()"
    error_msg_real "$msg" "$exit_code"
}

source_all_helpers() {
    #
    #  Sources the full helper environment, if not already loaded.
    #
    #  Initially, only helpers_minimal.sh is loaded for performance. It includes:
    #   - log_it / log_it_minimal
    #   - tmux_vers_check
    #   - safe_now & time_span (used by dialog_handling to log render speed)
    #   - error_msg (safe to call before full sourcing)
    #
    #  Use this to load all helpers when needed, ensuring it's only done once:
    #    ${b_all_helpers_sourced:-false} || source_all_helpers "caller description"
    #

    # log_it "source_all_helpers() - $1"
    ${b_all_helpers_sourced:-false} && {
        error_msg "source_all_helpers() called when it was already done - $1"
    }
    b_all_helpers_sourced=true # set it early to avoid recursion

    # shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
    . "$D_TM_BASE_PATH"/scripts/utils/helpers_full.sh || {
        error_msg "Failed to source: scripts/utils/helpers_full.sh"
    }
}

relative_path() {
    #
    # To fully avoid a fork, set $2=silent, and retrieve the value via _rp_proj_path:
    #   relative_path "$foo" silent
    #   rel_foo="$_rp_proj_path"
    # otherwise the more expensive but easier to code usage is the more typical:
    #   rel_foo=$(relative_path "$foo")
    #
    _rp_in="$1"
    _rp_old_pwd="$PWD"

    case "$_rp_in" in
        /*)
            # Already absolute
            _rp_full_path="$_rp_in"
            ;;
        *)
            # Relative path - convert to absolute
            _rp_dir="${_rp_in%/*}"
            _rp_bn="${_rp_in##*/}" # same but faster than "$(basename "$0")"

            # No directory component means current directory
            [ "$_rp_dir" = "$_rp_in" ] && _rp_dir="."

            # cd to normalize the path (builtin, no fork)
            cd -- "$_rp_dir" || error_msg "relative_path() - failed to cd $_rp_dir"
            _rp_full_path="$PWD/$_rp_bn"
            cd -- "$_rp_old_pwd" || error_msg "relative_path() - failed to cd $_rp_old_pwd"
            ;;
    esac

    # Extract project-relative path by removing prefix
    _rp_proj_path="${_rp_full_path#"$D_TM_BASE_PATH"/}"

    [ "$2" != silent ] && printf '%s' "$_rp_proj_path"
}

validate_varname() {
    case "$1" in
        [a-zA-Z_][a-zA-Z0-9_]*) return 0 ;;
        *) error_msg "$2 Invalid variable name: $1" ;;
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

        # shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
        . "$f_cache_params" || {
            # restore forced log file setting if sourcing failed
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
    if [ -f "$f_cache_params" ]; then
        source_cached_params || {
            replace_config=true
            _m="WARNING: get_config() failed to source: $f_cache_params,"
            _m="$_m calling config_setup"
            log_it "$_m"
        }
    elif [ -f "$f_no_cache_hint" ]; then
        cfg_use_cache=false
        ${b_all_helpers_sourced:-false} || {
            source_all_helpers "get_config() - no cache hint found"
        }
        tmux_get_plugin_options
        # ckoud node .16 jacmacm 0.32 jacpad 1.5  jacdroid 1.2
        check_speed_cutoff 0.6
    else
        replace_config=true
    fi

    if ${replace_config:-false}; then
        ${b_all_helpers_sourced:-false} || {
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

get_env() {
    [ -n "$env_unmame" ] || env_unmame="$(uname -s)"
}

menu_handler_cache_missmatch() {
    # Report a mismatch between TMUX_MENUS_HANDLER and current cache

    msg="TMUX_MENUS_HANDLER=$TMUX_MENUS_HANDLER"
    [ -n "$1" ] && msg="$msg ($1)"
    msg="$msg does not match current cache:\n\n"
    msg="$msg    b_use_alt_handler=$b_use_alt_handler\n"
    msg="$msg    alt_menu_handler=$alt_menu_handler"
    error_msg "$msg"
}

verify_menu_handler_override_valid() {
    # Ensure manual override of menu handler is not a mismatch vs current cache

    ${initialize_plugin:-false} && return # not relevant during plugin init
    # log_it "verify_menu_handler_override_valid($requested_handler)"
    requested_handler="$1"
    ${cfg_use_cache:-false} || return # irrelevant check when not using cache

    if ! ${b_use_alt_handler:-false} || [ "$alt_menu_handler" != "$requested_handler" ]; then
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
        0) ${b_use_alt_handler:-false} && verify_menu_handler_override_valid "tmux display-menu" ;;
        1)
            _cmd=whiptail
            verify_menu_handler_override_valid "$_cmd"
            if command -v "$_cmd" >/dev/null; then
                alt_menu_handler="$_cmd"
            else
                error_msg "$_cmd not available, plugin aborted"
            fi
            b_use_alt_handler=true
            ${initialize_plugin:-false} && {
                log_it "NOTICE: $_cmd is selected due to TMUX_MENUS_HANDLER=1"
            }
            b_whiptail_forced=true
            ;;
        2)
            _cmd=dialog
            verify_menu_handler_override_valid "$_cmd"
            if command -v "$_cmd" >/dev/null; then
                alt_menu_handler="$_cmd"
            else
                error_msg "$_cmd not available, plugin aborted"
            fi
            b_use_alt_handler=true
            ${initialize_plugin:-false} && {
                log_it "NOTICE: $_cmd is selected due to TMUX_MENUS_HANDLER=2"
            }
            b_whiptail_forced=true
            ;;
        *)
            msg="TMUX_MENUS_HANDLER=$TMUX_MENUS_HANDLER - valid options: 0 1 2"
            error_msg "$msg"
            ;;
    esac

    ${b_whiptail_forced:-false} && {
        ${b_all_helpers_sourced:-false} || {
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

timers_disabled() {
    ! ${initialize_plugin:-false} && ! ${cfg_use_timers:-false}
}

select_safe_now_method() { # local usage by safe_now()
    #
    # Select and save the time method for future use.
    # Using milliseconds when possible
    #
    # Provides: selected_safe_now_mthd
    #
    [ -n "$selected_safe_now_mthd" ] && {
        error_msg "Recursive call to: select_safe_now_method"
    }
    # log_it "select_safe_now_method()"

    [ -f "$f_safe_now_method" ] && {
        IFS= read -r selected_safe_now_mthd <"$f_safe_now_method" || {
            error_msg "Failed to read: $f_safe_now_method"
        }
        return
    }
    # Probe actual output: %3N is a GNU extension, displaying ms
    # BSD / MacOS  Displays N at end of output
    # BusyBox date silently ignores it and returns seconds only
    # — so test the output length rather than inferring from OS
    _snm_test="$(date +%s%3N 2>/dev/null)"
    if [ "${#_snm_test}" -ge 13 ]; then
        selected_safe_now_mthd="date" # date supports ms precision
    elif command -v gdate >/dev/null; then
        selected_safe_now_mthd="gdate" # macOS with GNU date
    elif command -v perl >/dev/null; then
        selected_safe_now_mthd="perl" # fallback via Perl
    else
        selected_safe_now_mthd="seconds" # last resort, seconds-only
    fi
    unset _snm_test
    [ -d "$d_cache" ] && {
        # Only save to cache folder if it has been created.
        # This avoids gotchas if this is called before  cache disabled has been
        # checked
        echo "$selected_safe_now_mthd" >"$f_safe_now_method" || {
            error_msg "Failed to save: $f_safe_now_method"
        }
    }
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

    # always run during plugin init, otherwise only if cfg_use_timers is true
    timers_disabled && {
        # Don't use timers
        t_now=0
        [ -n "$varname" ] && {
            # if variable name provided set it to t_now
            eval "$varname=\"\$t_now\""
        }
        return
    }

    # [ -n "$selected_safe_now_mthd" ] && {
    #     # first call will have no method defined, so this will recurse once it is
    #     # set
    #     log_it "safe_now($varname) mthd: [$selected_safe_now_mthd]"
    # }

    case "$selected_safe_now_mthd" in
        date) t_now="$(date +%s.%N)" ;;
        gdate) t_now="$(gdate +%s.%N)" ;;
        perl) t_now="$(perl -MTime::HiRes=time -E '$t = time; printf "%.9f\n", $t')" ;;
        seconds) t_now="$(date +%s)" ;;
        *)
            select_safe_now_method

            # to prevent infinite recursion, eunsure a valid timing method is now selected
            case "$selected_safe_now_mthd" in
                date | gdate | perl | seconds) ;;
                *)
                    error_msg \
                        "safe_now($varname) - failed to select a timing method"
                    ;;
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
    timers_disabled && {
        # Don't use timers
        t_time_span=1
        return
    }

    _t_start="$1"

    safe_now # assigns t_now

    if [ -d /proc/ish ]; then
        # iSH performs better with bc due to emulation characteristics
        t_time_span="$(echo "$t_now - $_t_start" | bc)"
    else
        t_time_span="$(awk "BEGIN {print $t_now - $_t_start}")"
    fi
}

#---------------------------------------------------------------
#
#   tmux version related support functions
#
#---------------------------------------------------------------

tmux_vers_check() { # local usage when checking $min_tmux_vers
    _v_comp="$1"    # Desired minimum version to check against
    # log_it "tmux_vers_check($_v_comp)"
    [ -z "$_v_comp" ] && error_msg "tmux_vers_check() - no parameter given"

    # Retrieve and cache the current tmux version on the first call,
    # unless it has been read from the param cache
    if [ -z "$current_tmux_vers" ] || [ -z "$current_tmux_vers_i" ]; then
        tpt_retrieve_running_tmux_vers
    fi

    if [ -z "$cached_ok_tmux_versions" ] && [ -f "$f_cache_known_tmux_vers" ]; then
        # Reading it if existing is harmless even if cache is disabled
        # shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
        . "$f_cache_known_tmux_vers" || {
            log_it "WARNING: Failed to source: f_cache_known_tmux_vers"
            # Since the source failed, clear these in orde to ensure no bad
            # state was retrieved
            cached_ok_tmux_versions=""
            cached_bad_tmux_versions=""
        }
    fi

    # Check if the version is in the cached good or bad lists using case statements
    case "$cached_ok_tmux_versions" in
        *" $_v_comp "*) return 0 ;; # Version found in good list
        *) ;;
    esac
    case "$cached_bad_tmux_versions" in
        *" $_v_comp "*) return 1 ;; # Version found in bad list
        *) ;;
    esac

    # Once a menu has been processed once, all version references should already be
    # cached, so in the normal cached state this point will not be reached

    # If helpers aren't sourced yet, source them before continuing the version check
    ${b_all_helpers_sourced:-false} || {
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
    current_tmux_vers=$($TMUX_BIN -V | cut -d' ' -f2)
    case "$current_tmux_vers" in
        "2.4."*) current_tmux_vers="2.4" ;; # handle tmate triple digits
        *) ;;
    esac

    tpt_parse_tmux_vers "$current_tmux_vers"
    current_tmux_vers_i="$tpt_vers_digits"
    current_tmux_vers_suffix="$tpt_vers_suffix"
}

tpt_parse_tmux_vers() {
    # converts the given tmux version into our simplified notation
    # Provides:
    #   tpt_vers_digits
    #   tpt_vers_suffix
    #
    #   "tmux 3.7" => tpt_vers_digits="37" tpt_suffix=""
    #   "3.7a"     => tpt_vers_digits="37" tpt_suffix="a"
    #   "tmux next-3.8" => tpt_vers_digits="37" tpt_suffix="z"
    #
    _vers=$1
    [ -z "$_vers" ] && error_msg "tpt_parse_tmux_vers() - no param"
    _vers=${_vers%%-rc*} # Remove trailing "-rc" and anything after

    # Helper: Apply "next-" version reduction consistently
    # Reduces next-X.Y versions: next-X.0 => (X-1).9, next-X.Y => X.(Y-1)
    case $_vers in
        next-*)
            _vers="${_vers#next-}"          # Strip "next-" prefix
            _major="${_vers%.*}"            # Everything before last dot
            _minor="${_vers#*.}"            # Everything after first dot
            _minor_num="${_minor%%[^0-9]*}" # Keep only leading digits

            if [ "$_minor_num" -eq 0 ] 2>/dev/null; then
                # next-X.0: decrement major, set minor to 9
                _vers="$((_major - 1)).9"
            else
                # next-X.Y (Y>0): decrement minor
                # ensure the next version has the last suffix, ending in a virtual subvers
                # higher than any actual release
                _vers="${_major}.$((_minor_num - 1))z"
            fi
            ;;
        *) ;; # no reduction needed
    esac

    # Extract only digits from version string
    tpt_vers_digits=""
    _tpvd_temp="$_vers"
    while [ -n "$_tpvd_temp" ]; do
        _tpvd_char="${_tpvd_temp%"${_tpvd_temp#?}"}" # Get first character
        case "$_tpvd_char" in
            [0-9]) tpt_vers_digits="$tpt_vers_digits$_tpvd_char" ;;
            *) ;;
        esac
        _tpvd_temp="${_tpvd_temp#?}" # Remove first character
    done
    # Check if result is empty after digit extraction
    [ -z "$tpt_vers_digits" ] && error_msg "tpt_vers_digits - result empty"

    # Remove leading digits, dots, and dashes to isolate non-rc suffix
    tpt_vers_suffix=$(printf "%s" "$_vers" | sed 's/^[0-9.-]*//')
}

base_path_not_defined() {
    # Show error msg if D_TM_BASE_PATH is not defined
    # helpers not yet sourced, so TMUX_BIN & error_msg() not yet available
    msg="$plugin_name ERROR: $0 - D_TM_BASE_PATH must be set before sourcing this file"
    print_stderr "$msg"
    $TMUX_BIN display-message "$msg"
    exit 1
}

#===============================================================
#
#   Main
#
#===============================================================

#---------------------------------------------------------------
#
#  Early debug options
#
#  Define before anything else. Normally commented out.
#
#---------------------------------------------------------------

# cfg_use_timers=true # will be set during get_config

#
# Hardcoded log file for early startup tracing (before @menus_log_file is
# read). If log_file_forced=1, @menus_log_file is ignored and this remains.
#
# cfg_log_file="$HOME/tmp/tmux-menus-dbg.log"
# log_file_forced=1

TMUX_BIN="${TMUX_BIN:-tmux}"

[ -n "$env_initialized" ] && error_msg "helpers_minimal already sourced []"

env_initialized=0 # also matches for "" - basic init done

plugin_name="tmux-menus"

#
#  If set to 1 log will happen to stderr if script is run in an interactive
#  shell, so this will not mess it up if the plugin is initiated or run by tmux
#  If log can't happen to stderr, it will go to @menus_log_file if it is defined
#
log_interactive_to_stderr="${log_interactive_to_stderr:-0}"

min_tmux_vers=1.5 # oldest accepted tmux version

# for performance only a minimum of support features are in this file
# as long as cache is used, it is sufficient, if extra features are needed
# a call to source_all_helpers will be done, this ensures it only happens once
b_all_helpers_sourced=false

d_tmp="${TMPDIR:-/tmp}"
d_tmp="${d_tmp%/}" # Removes a trailing slash if present - sometimes set in TMPDIR...
f_no_cache_hint="$d_tmp"/tmux-menus-no-cache-hint

[ -z "$D_TM_BASE_PATH" ] && base_path_not_defined

d_scripts="$D_TM_BASE_PATH"/scripts
d_items="$D_TM_BASE_PATH"/items
d_help="$d_items"/help
d_cache="$D_TM_BASE_PATH"/cache
f_cache_known_tmux_vers="$d_cache"/known_tmux_versions
f_cache_params="$d_cache"/plugin_params
f_safe_now_method="$d_cache"/safe_now_method
f_max_25_line_menus="$d_cache"/height-max-25-lines

# Used if main menu cache should be purged, like if custom_items are detected
# or found to be gone
d_cache_main_menu="$d_cache"/items/main.sh

# System-initial default for the main menu.
# After options are parsed, always use $cfg_main_menu to refer to the current main menu.
# This ensures any user-defined main menu or redirections are respected.
f_main_menu="$d_items"/main.sh

f_ext_dlg_trigger="$d_scripts/external_dialog_trigger.sh"
scr_float_pane_switch="$d_scripts/floating_pane_switch.sh"

bn_current_script=${0##*/} # same but faster than "$(basename "$0")"

relative_path "$0" silent
rn_current_script="$_rp_proj_path"

# current_script_no_ext=${rn_current_script%.*} # not used ATM

# --->  Only enable this if profiling is being used during startup  <---
# [ "$profiling_sourced" != 1 ] && {
#     # shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
#     . "$D_TM_BASE_PATH"/scripts/utils/dbg_profiling.sh
# }

# Set this as early as possible to be able to calculate the entire menu processing time
# This depends on cfg_use_timers, so can't be done before config is processed
safe_now t_script_start

${initialize_plugin:-false} || {
    # plugin_init will call config_setup directly, so should not call get_config
    get_config
}

# The initial safe_now returned 0, since it was run before config had
# been checked, and would only return a time if initialize_plugin is set
# Now config has been read and it's known if a time should be returned or not
[ "$t_now" = 0 ] && safe_now t_script_start

if ! tmux_vers_check "$min_tmux_vers"; then
    # @variables are not usable prior to 1.8
    error_msg "$plugin_name needs at least tmux $min_tmux_vers to work properly."
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
f_cached_tmux_key_binds="$d_safe_tmp_folder"/tmux_key_binds

[ "${env_initialized:-0}" -lt 1 ] && env_initialized=1 # also matches for "" - basic init done

# log_it "><> [$$] scripts/helpers_minimal.sh - completed [$0]"
