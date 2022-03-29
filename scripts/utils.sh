#!/bin/sh
# Always sourced file - Fake bangpath to help editors
# shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.3.4 2022-03-29
#
#  Common stuff
#


#
#  Shorthand, to avoid manually typing package name on multiple
#  locations, easily getting out of sync.
#
plugin_name="tmux-menus"


#
#  If log_file is empty or undefined, no logging will occur,
#  so comment it out for normal usage.
#
#log_file="/tmp/$tmux-menus.log"  # Trigger LF to separate runs of this script




#
#  If $log_file is empty or undefined, no logging will occur.
#
log_it() {
    if [ -z "$log_file" ]; then
        return
    fi
    printf "%s\n" "$@" >> "$log_file"
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

        "yes" | "Yes" | "YES" | "true" | "True" | "TRUE" )
            #  Be a nice guy and accept some common positives
            log_it "Converted incorrect positive [$1] to 1"
            return 0
            ;;

        "no" | "No" | "NO" | "false" | "False" | "FALSE" )
            #  Be a nice guy and accept some common negatives
            log_it "Converted incorrect negative [$1] to 0"
            return 1
            ;;

        *)
            log_it "Invalid parameter bool_param($1)"
            tmux display "ERROR: bool_param($1) - should be 0 or 1"

    esac
    return 1
}


get_tmux_option() {
    gtm_option=$1
    gtm_default=$2
    gtm_value=$(tmux show-option -gqv "$gtm_option")
    if [ -z "$gtm_value" ]; then
        echo "$gtm_default"
    else
        echo "$gtm_value"
    fi
    unset gtm_option
    unset gtm_default
    unset gtm_value
}


#
#  Must come after definition of get_tmux_option to be able
#  to use it.
#
menu_location_x="$(get_tmux_option "@menus_location_x" "P")"
menu_location_y="$(get_tmux_option "@menus_location_y" "P")"

