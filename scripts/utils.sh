#!/bin/sh
# Always sourced file - Fake bangpath to help editors
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Common stuff
#

#  shellcheck disable=SC2034,SC2154
#  Directives for shellcheck directly after bang path are global

#
#  Shorthand, to avoid manually typing package name on multiple
#  locations, easily getting out of sync.
#
plugin_name="tmux-menus"

#
#  If log_file is empty or undefined, no logging will occur,
#  so comment it out for normal usage.
#
#log_file="/tmp/$plugin_name.log"

#
#  If @menus_config_overrides is 1, this file is used to store
#  custom settings. If it is missing, it will be re-created with defaults
#
config_file="/tmp/tmux-menus.conf"

#
#  I use an env var TMUX_BIN to point at the current tmux, defined in my
#  tmux.conf, in order to pick the version matching the server running.
#  This is needed when checking backwards compatability with various versions.
#  If not found, it is set to whatever is in path, so should have no negative
#  impact. In all calls to tmux I use $TMUX_BIN instead in the rest of this
#  plugin.
#
[ -z "$TMUX_BIN" ] && TMUX_BIN="tmux"

#
#  If available, is expected to point to conf file for this environment
#
[ -z "$TMUX_CONF" ] && TMUX_CONF="$HOME/.tmux.conf"

#
#  If $log_file is empty or undefined, no logging will occur.
#
log_it() {
    if [ -z "$log_file" ]; then
        return
    fi
    printf "[%s] %s\n" "$(date '+%H:%M:%S')" "$@" >>"$log_file"
}

#
#  Display $1 as an error message in log and as a tmux display-message
#  If no $2 or set to 0, process is not exited
#
error_msg() {
    em_msg="ERROR: $1"
    em_exit_code="${2:-0}"

    log_it "$em_msg"
    em_msg="$plugin_name $em_msg"
    em_msg_len="$(printf "%s" "$em_msg" | wc -m)"
    em_screen_width="$($TMUX_BIN display -p "#{window_width}")"
    if [ "$em_msg_len" -le "$em_screen_width" ]; then
        $TMUX_BIN display-message "$em_msg"
    else
        #
        #  Screen is to narrow to use display message
        #  By echoing it, it will be displayed in a copy-mode
        #
        echo
        echo "$em_msg"
    fi
    [ "$em_exit_code" -ne 0 ] && exit "$em_exit_code"
}

#
#  Aargh in shell boolean true is 0, but to make the boolean parameters
#  more relatable for users 1 is yes and 0 is no, so we need to switch
#  them here in order for assignment to follow boolean logic in caller
#
bool_param() {
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

get_tmux_option() {
    gtm_option=$1
    gtm_default=$2
    gtm_value=$($TMUX_BIN show-option -gqv "$gtm_option")
    if [ -z "$gtm_value" ]; then
        echo "$gtm_default"
    else
        echo "$gtm_value"
    fi
    unset gtm_option
    unset gtm_default
    unset gtm_value
}

write_config() {
    [ "$config_overrides" -ne 1 ] && return
    #log_it "write_config() x[$location_x] y[$location_y]"
    echo "location_x=$location_x" >"$config_file"
    echo "location_y=$location_y" >>"$config_file"
}

read_config() {
    [ "$config_overrides" -ne 1 ] && return
    #log_it "read_config()"
    if [ ! -f "$config_file" ]; then
        location_x=P
        location_y=P
        write_config
    fi
    #  shellcheck disable=SC1090
    . "$config_file"
    [ -z "$location_x" ] && location_x="P"
    [ -z "$location_y" ] && location_y="P"
}

tmux_vers_compare() {
    check_vers="$1"
    tmux_vers_file="$SCRIPT_DIR/.tmux_version"
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

#
#  Convert to boolean status from the dropox (python?) status logic
#  where 1 means running and 0 means not running
#
is_dropbox_running() {
    dropbox running && return 1
    if [ "$(dropbox status)" = "Syncing..." ]; then
        #  status is only this whilst terminating, during normal operations
        #  it also mentions what file (-s) is being synced.
        #  So this is a sure sign dropbox is about to shut down,
        #  so can be labeled asnot running
        return 1
    else
        # is running
        return 0
    fi
}

current_script="$CURRENT_DIR/$(basename "$0")"

#
#  This is for shells checking status.
#  In tmux code #{?@menus_config_overrides,,} can be used
#
if bool_param "$(get_tmux_option "@menus_config_overrides" "0")"; then
    config_overrides=1
else
    config_overrides=0
fi
#log_it "config_overrides=[$config_overrides]"

if [ "$config_overrides" -eq 1 ] && [ -f "$config_file" ]; then
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
