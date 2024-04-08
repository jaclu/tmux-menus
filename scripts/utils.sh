#!/bin/sh
# Always sourced file - Fake bang path to help editors
#  shellcheck disable=SC2034,SC2154
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Common tools and settings for this plugins
#

log_it() {
    #
    #  If $log_file is empty or undefined, no logging will occur.
    #
    if [ -z "$log_file" ]; then
        return
    fi
    printf "[%s] %s\n" "$(date '+%H:%M:%S')" "$@" >>"$log_file"
}

error_msg() {
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

error_missing_param() {
    #
    #  Shortcut for repeatedly used error message type
    #
    param_name="$1"
    if [ -z "$param_name" ]; then
        error_msg "dialog_handling.sh:error_missing_param() called without parameter"
    fi
    error_msg "dialog_handling.sh: $param_name must be defined!"
}

bool_param() {
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
        error_msg "bool_param($1) - should be 1/yes/true or 0/no/false"
        ;;

    esac
    return 1 # default to False
}

get_mtime() {
    _fname="$1"
    if [ "$(uname)" = "Darwin" ]; then
        # macOS version
        stat -f "%m" "$_fname"
    else
        # Linux version
        stat -c "%Y" "$_fname"
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
    [ "$config_overrides" -ne 1 ] && return
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

tmux_vers_compare() {
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

#
#  This is for shells checking status.
#  In tmux code #{?@menus_config_overrides,,} can be used
#
if bool_param "$(get_tmux_option "@menus_config_overrides" "0")"; then
    config_overrides=1
else
    config_overrides=0
fi

if bool_param "$(get_tmux_option "@menus_use_cache" "yes")"; then
    use_cache=true
else
    use_cache=false
fi

if [ "$config_overrides" -eq 1 ] && [ -f "$custom_config_file" ]; then
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
#  Define a variable that can be used as suffix on commands in dialog
#  items, to reload the same menu in calling scripts
#
if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
    # shellcheck disable=SC2034
    menu_reload="; '$current_script'"
    D_TM_MENUS_CACHE="$D_TM_BASE_PATH"/cache/whiptail
else
    # shellcheck disable=SC2034
    menu_reload="; run-shell '$current_script'"
    D_TM_MENUS_CACHE="$D_TM_BASE_PATH"/cache
fi

#
#  All calling scripts must provide
#

D_TM_SCRIPTS="$D_TM_BASE_PATH"/scripts
D_TM_ITEMS="$D_TM_BASE_PATH"/items

# [ "$(basename "$0")" = "menus.tmux" ] && return
