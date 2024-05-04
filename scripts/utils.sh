#!/bin/sh
# Always sourced file - Fake bang path to help editors
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Common tools and settings for this plugins
#
# shellcheck disable=SC2034

#---------------------------------------------------------------
#
#   Logging and error msgs
#
#---------------------------------------------------------------

log_it() {
    [ -z "$cfg_log_file" ] && return #  early abort if no logging
    #
    #  If @packet-loss-log_file is defined, it will be read into the
    #  cfg_log_file variable and used for logging.
    #
    #  Logging should normally be disabled, since it causes some overhead.
    #

    $log_interactive_to_stderr && [ -t 0 ] && {
        printf "log: %s%*s%s\n" "$log_prefix" "$log_indent" "" \
            "$@" >/dev/stderr
        return
    }

    if [ "$log_ppid" = "true" ]; then
        proc_id="$(tmux display -p "#{session_id}"):$PPID"
    else
        proc_id="$$"
    fi

    #  needs leading space for compactness in the printf if empty
    socket=" $(get_tmux_socket)"
    #  only show socket name if not default
    # [[ "$socket" = " default" ]] && socket=""

    # printf "[%s] %s\n" "$(date '+%H:%M:%S')" "$@" >>"$log_file"
    printf "%s%s %s %s%*s%s\n" "$(date +%H:%M:%S)" "$socket" "$proc_id" \
        "$log_prefix" "$log_indent" "" "$@" >>"$cfg_log_file"
    unset socket
}

error_msg() {
    #
    #  Display $1 as an error message in log and as a tmux display-message
    #  If $2 is set to 0, process is not exited
    #
    msg="ERROR: $1"
    exit_code="${2:-1}"
    display_message=${3:-false}

    if $log_interactive_to_stderr && [ -t 0 ]; then
        echo "$msg" >/dev/stderr
    else
        log_it
        log_it "$msg"
        log_it
        $display_message && {
            # only display exit triggering errors on status bar
            $TMUX_BIN display-message -d 0 "tmux-menus:$msg"
        }
    fi
    [ "$exit_code" -gt 0 ] && exit "$exit_code"

    unset msg
    unset exit_code
    unset display_message
}

old_error_msg() {
    #
    #  Display $1 as an error message in the log and as a tmux display-message
    #  If no $2 or set to 0, the process is not exited
    #
    em_msg="ERROR: tmux-menus:$(basename "$0") $1"
    em_exit_code="${2:-1}"
    em_msg_len="$(printf "%s" "$em_msg" | wc -m)"
    em_screen_width="$($TMUX_BIN display -p "#{window_width}")"

    if [ -n "$log_file" ]; then
        log_it "$em_msg"
    else
        #
        #  Error msgs should always be displayed. If logging is not on
        #  print to stdout
        #
        echo
        echo "$em_msg"
        echo
    fi

    [ "$em_exit_code" -ne 0 ] && exit "$em_exit_code"
}

#---------------------------------------------------------------
#
#   bool params
#
#---------------------------------------------------------------

param_as_bool() {
    #  Used to parse variables assigned "true" or "false" as booleans
    [ "$1" = "true" ] && return 0
    return 1
}
# FOO123
normalize_bool_param() {
    #
    #  Ensure boolean style params use consistent states
    #
    case "$1" in
    #
    #  First handle the mindboggling tradition by tmux to use
    #  1 to indicate selected / active.
    #  This means 1 is 0 and 0 is 1, how Orwellian...
    #
    "1" | "yes" | "Yes" | "YES" | "true" | "True" | "TRUE")
        #  Be a nice guy and accept some common positive notations
        return 0
        ;;

    "0" | "no" | "No" | "NO" | "false" | "False" | "FALSE")
        #  Be a nice guy and accept some common false notations
        return 1
        ;;

    *)
        log_it "Invalid parameter normalize_bool_param($1)"
        error_msg \
            "normalize_bool_param($1) - should be yes/true/1 or no/false/0" \
            1 true
        ;;

    esac

    return 2
}

NOT_bool_param() {
    #
    #  Aargh in shell boolean true is 0, but to make the boolean parameters
    #  more relatable for users 1 is yes and 0 is no, so we need to switch
    #  them here for assignment to follow boolean logic in the caller
    #
    case "$1" in

    "0") return 1 ;;

    "1") return 0 ;;

    "yes" | "Yes" | "YES" | "true" | "True" | "TRUE")
        #  Be a nice guy and accept some common positives
        log_it "Converted positive [$1] to 0"
        return 0
        ;;

    "no" | "No" | "NO" | "false" | "False" | "FALSE")
        #  Be a nice guy and accept some common negatives
        log_it "Converted negative [$1] to 1"
        return 1
        ;;

    *)
        error_msg "NOT_bool_param($1) - should be 1/yes/true or 0/no/false"
        ;;

    esac
    return 1 # default to False
}

#---------------------------------------------------------------
#
#   tmux env handling
#
#---------------------------------------------------------------

get_tmux_socket() {
    #
    #  returns name of tmux socket being used
    #
    if [ -n "$TMUX" ]; then
        echo "$TMUX" | sed 's#/# #g' | cut -d, -f 1 | awk 'NF>1{print $NF}'
    else
        echo "standalone"
    fi
}

get_tmux_option() {
    gtm_option=$1
    gtm_default=$2
    gtm_value=$($TMUX_BIN show-option -gv "$gtm_option" 2>/dev/null)
    if [ -z "$gtm_value" ]; then
        echo "$gtm_default"
    else
        echo "$gtm_value"
    fi
    unset gtm_option
    unset gtm_default
    unset gtm_value
}

read_config() {
    #
    #  When config_overrides is set this reads such settings
    #
    $config_overrides || return
    # [ "$config_overrides" -ne 1 ] && return
    #log_it "read_config()"
    if [ ! -f "$custom_config_file" ]; then
        location_x=P
        location_y=P
        write_config
    fi
    #  shellcheck disable=SC1090
    . "$custom_config_file"
    [ -z "$location_x" ] && location_x="P"
    [ -z "$location_y" ] && location_y="P"
}

compare_floats() {
    awk -v n1="$1" -v n2="$2" 'BEGIN { exit !(n1 >= n2) }'
}

tmux_vers_compare() {
    #
    #  This returns true if v1 <= v2
    #  If only one param is given it is compared vs version of running tmux
    #
    tvc_v1="$1"
    tvc_v2="${2:-$tmux_vers}"

    # log_it "tmux_vers_compare($v1, $v2)"

    # insert . between each char for consistent notation
    tvc_v1="$(echo "$tvc_v1" | sed 's/[^.]/.&/g' | sed 's/\.\././g' | sed 's/^\.//;s/\.$//')"
    tvc_v2="$(echo "$tvc_v2" | sed 's/[^.]/.&/g' | sed 's/\.\././g' | sed 's/^\.//;s/\.$//')"

    tvc_idx=1
    while true; do
        tvc_c="$(echo "$tvc_v1" | cut -d. -f "$tvc_idx")"
        tvc_i1="$(printf "%d" "'$tvc_c")"
        tvc_c="$(echo "$tvc_v2" | cut -d. -f "$tvc_idx")"
        tvc_i2="$(printf "%d" "'$tvc_c")"
        if [ "$tvc_i2" = 0 ] || [ "$tvc_i1" -lt "$tvc_i2" ]; then
            tvc_rslt=0
            break
        elif [ "$tvc_i1" = 0 ] || [ "$tvc_i1" -gt "$tvc_i2" ]; then
            tvc_rslt=1
            break
        fi
        tvc_idx=$((tvc_idx + 1))
    done

    # log_it "tmux_vers_compare: $v1 <= $v2 -  $tvc_rslt"

    unset tvc_v1
    unset tvc_v2
    unset tvc_idx
    unset tvc_c
    unset tvc_i1
    unset tvc_i2
    return "$tvc_rslt"
}

old_tmux_vers_compare() {
    #
    #  Compares running vs required version, to define if a feature
    #  can be used in this env
    #
    check_vers="$1"

    #
    #  The time to generate it each time is pretty much the same
    #  as reading the value from a cached file, so just not worth the
    #  risk of getting the wrong version indicated after an upgrade
    #
    tmux_vers="$($TMUX_BIN -V | cut -d ' ' -f 2)"

    # shellcheck disable=SC3012
    if [ "$check_vers" \> "$tmux_vers" ]; then
        # echo ">> vers mismatch"
        return 1
    fi
    # echo ">> version ok"
    return 0
}

#---------------------------------------------------------------
#
#   Other
#
#---------------------------------------------------------------

wait_to_close_display() {
    echo
    if [ "$FORCE_WHIPTAIL_MENUS" = 1 ] || ! tmux_vers_compare 3.0; then
        echo "Press <Enter> to clear this output"
        read -r foo
    else
        echo "Press <Escape> to clear this output"
    fi
}

#===============================================================
#
#   Main
#
#===============================================================

[ -z "$D_TM_BASE_PATH" ] && error_msg "D_TM_BASE_PATH undefined"

#
#  If log_file is empty or undefined, no logging will occur,
#  so comment it out for normal usage.
#
# log_file="/tmp/tmux-menus.log"

#
#  If @menus_config_overrides is 1, this file is used to store
#  custom settings. If it is missing, it will be re-created with defaults
#
custom_config_file="/tmp/tmux-menus.conf"

#
#  I use an env var TMUX_BIN to point at the current tmux, defined in my
#  tmux.conf, to pick the version matching the server running.
#  This is needed when checking backward compatibility with various versions.
#  If not found, it is set to whatever is in the path, so should have no negative
#  impact. In all calls to tmux I use $TMUX_BIN instead in the rest of this
#  plugin.
#
[ -z "$TMUX_BIN" ] && TMUX_BIN="tmux"

if ! tmux_vers_compare 1.7; then
    error_msg "This needs at least tmux 1.7 to work!"
fi

#
#  Convert script name to full actual path notation the path is used
#  for caching, so save it to a variable as well
#

d_current_script="$(cd -- "$(dirname -- "$0")" && pwd)"
current_script="$d_current_script/$(basename "$0")"

tmux_vers="$($TMUX_BIN -V | cut -d ' ' -f 2)"

cfg_log_file="$(get_tmux_option "@menus_log_file" "")"
log_interactive_to_stderr=false

#
#  Define a variable that can be used as suffix on commands in dialog
#  items, to reload the same menu in calling scripts
#
if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
    menu_reload="; '$current_script'"
    d_cache="$D_TM_BASE_PATH"/cache/whiptail
else
    menu_reload="; run-shell '$current_script'"
    d_cache="$D_TM_BASE_PATH"/cache
fi

#
#  The plugin init script checks this at startup
#  if the running tmux version is not the same as the one that created
#  the cache, the cache is deleted
#
f_cached_tmux="$d_cache"/tmux-vers

#
#  This is for shells checking status.
#  In tmux code #{?@menus_config_overrides,,} can be used
#

normalize_bool_param "@menus_config_overrides" "No" &&
    config_overrides=true || config_overrides=false
# if bool_param "$(get_tmux_option "@menus_config_overrides" "0")"; then
#     config_overrides=1
# else
#     config_overrides=0
# fi

normalize_bool_param "@menus_use_cache" "Yes" &&
    use_cache=true || use_cache=false
# if bool_param "$(get_tmux_option "@menus_use_cache" "yes")"; then
#     use_cache=true
# else
#     use_cache=false
# fi

# if [ "$config_overrides" -eq 1 ] && [ -f "$custom_config_file" ]; then
if $config_overrides && [ -f "$custom_config_file" ]; then
    read_config
    menu_location_x="$location_x"
    menu_location_y="$location_y"
else
    #
    #  Must come after definition of get_tmux_option to be able
    #  to use it.
    #
    menu_location_x="$(get_tmux_option "@menus_location_x" "P")"
    menu_location_y="$(get_tmux_option "@menus_location_y" "P")"
fi

#
#  All calling scripts must provide
#

D_TM_SCRIPTS="$D_TM_BASE_PATH"/scripts
D_TM_ITEMS="$D_TM_BASE_PATH"/items

# [ "$(basename "$0")" = "menus.tmux" ] && return
