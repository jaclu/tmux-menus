#!/bin/sh
# Always sourced file - Fake bangpath to help editors
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.3.10 2022-05-08
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
log_file="/tmp/$plugin_name.log"


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

    em_msg="$plugin_name $em_msg"
    em_msg_len="$(printf "%s" "$em_msg" | wc -m)"
    em_screen_width="$(tmux display -p "#{window_width}")"
    if [ "$em_msg_len" -le "$em_screen_width" ]; then
	tmux display-message "$em_msg"
    else
	#  Screen is to narrow to use display message
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
            log_it "Converted incorrect positive [$1] to 0"
            return 0
            ;;

        "no" | "No" | "NO" | "false" | "False" | "FALSE" )
            #  Be a nice guy and accept some common negatives
            log_it "Converted incorrect negative [$1] to 1"
            return 1
            ;;

        *)
            log_it "Invalid parameter bool_param($1)"
            error_msg "bool_param($1) - should be 0 or 1"
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


ensure_menu_fits_on_screen() {
    [ "$t_start" -ne "$(date +'%s')" ] && return  # menu should have been displayed

    log_it "ensure_menu_fits_on_screen() $req_win_width req_win_height" "$menu_name"
    [ "$req_win_width" = "" ] && error_msg "ensure_menu_fits_on_screen() req_win_width not set" 1
    [ "$req_win_height" = "" ] && error_msg "ensure_menu_fits_on_screen() req_win_height not set" 1
    [ "$menu_name" = "" ] && error_msg "ensure_menu_fits_on_screen() menu_name not set" 1
    
    css_width="$(tmux display -p "#{window_width}")"
    log_it "Current width: $css_width"
    css_height="$(tmux display -p "#{window_height}")"
    log_it "Current height: $css_height"

    if [ "$css_width" -lt "$req_win_width" ] || [ "$css_height" -lt "$req_win_height" ]; then
	echo
	echo "menu '$menu_name'"
	echo "needs a screen size"
	echo "of at least $req_win_width x $req_win_height"
	exit 0  # Is needed if the screen was too small and menu failed to display
    fi
}

cache_file=/tmp/menus.cache

write_cache() {
    log_it "write_cache()"
    echo "#!/bin/sh" >> "$cache_file"
    echo "cached_location_x=$cached_location_x" > "$cache_file"
    echo "cached_location_y=$cached_location_y" > "$cache_file"
}

read_cache() {
    log_it "read_cache()"
    if [ ! -f "$cache_file" ]; then
        cached_location_x=0
        cached_location_y=0
        write_cache
    fi
    "$cache_file"
}


#
#  Must come after definition of get_tmux_option to be able
#  to use it.
#
menu_location_x="$(get_tmux_option "@menus_location_x" "P")"
menu_location_y="$(get_tmux_option "@menus_location_y" "P")"

