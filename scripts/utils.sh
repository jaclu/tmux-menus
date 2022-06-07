#!/bin/sh
# Always sourced file - Fake bangpath to help editors
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.4.5 2022-06-08
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
#  If $log_file is empty or undefined, no logging will occur.
#
log_it() {
    if [ -z "$log_file" ]; then
        return
    fi
    printf "[%s] %s\n" "$(date '+%H:%M:%S')" "$@" >> "$log_file"
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
    em_screen_width="$(tmux display -p "#{window_width}")"
    if [ "$em_msg_len" -le "$em_screen_width" ]; then
        tmux display-message "$em_msg"
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

        "yes" | "Yes" | "YES" | "true" | "True" | "TRUE" )
            #  Be a nice guy and accept some common positives
            log_it "Converted positive [$1] to 0"
            return 0
            ;;

        "no" | "No" | "NO" | "false" | "False" | "FALSE" )
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
#  Since tmux display-menu returns 0 even if it failed to display the menu
#  due to not fitting on the screen, for now I check how long the menu
#  was displayed. If the seconds didn't tick up, inspect required size vs
#  actual screen size, and display a message if the menu doesn't fit.
#
#  This depends on the correct $req_win_width and $req_win_height having been
#  set, and that this sequence is done in the menu code:
#
#    t_start="$(date +'%s')"
#    tmux display-menu ...
#    ensure_menu_fits_on_screen
#
#  Not perfect, but it kind of works. If you hit escape and instantly close
#  the menu, a time diff zero might trigger this to check sizes, but if
#  the menu fits on the screen, no size warning will be printed.
#
#  This gets slightly more complicated with tmux 3.3, since now tmux shrinks
#  menus that don't fit due to width, so tmux might decide it can show a menu,
#  but due to shrinkage, the hints in the menu might be so shortened that they
#  are off little help explaining what this option would do.
#
ensure_menu_fits_on_screen() {
    [ "$t_start" -ne "$(date +'%s')" ] && return  # should have been displayed

    #
    #  Param checks
    #
    msg="ensure_menu_fits_on_screen() req_win_width not set"
    [ "$req_win_width" = "" ] && error_msg "$msg" 1
    msg="ensure_menu_fits_on_screen() req_win_height not set"
    [ "$req_win_height" = "" ] && error_msg "$msg" 1
    msg="ensure_menu_fits_on_screen() menu_name not set"
    [ "$menu_name" = "" ] && error_msg "$msg" 1

    set -- "ensure_menu_fits_on_screen() '$menu_name'" \
           "w:$req_win_width h:$req_win_height"
    log_it "$*"

    cur_width="$(tmux display -p "#{window_width}")"
    log_it "Current width: $cur_width"
    cur_height="$(tmux display -p "#{window_height}")"
    log_it "Current height: $cur_height"

    if    [ "$cur_width" -lt "$req_win_width" ] || \
          [ "$cur_height" -lt "$req_win_height" ]; then
        echo
        echo "menu '$menu_name'"
        echo "needs a screen size"
        echo "of at least $req_win_width x $req_win_height"
    fi
}


write_config() {
    [ "$config_overrides" -ne 1 ] && return
    #log_it "write_config() x[$location_x] y[$location_y]"
    echo "location_x=$location_x" > "$config_file"
    echo "location_y=$location_y" >> "$config_file"
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


if [ $config_overrides -eq 1 ] && [ -f "$config_file" ]; then
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
