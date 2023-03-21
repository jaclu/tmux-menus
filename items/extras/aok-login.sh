#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Directly control iSH-AOK
#

# Global check exclude
# shellcheck disable=SC2034,SC2154

display_login_method() {
    if ls -l /bin/login | grep -q login.loop; then
        echo "enabled"
    elif ls -l /bin/login | grep -q login.once; then
        echo "once"
    else
        echo "disabled"
    fi
}

disable_if_matching() {
    [ "$1" = "$(display_login_method)" ] && echo "-"
}

if [ "$(cat /proc/ish/defaults/enable_multicore)" = "true" ]; then
    multicore_act_lbl="disable"
    multicore_action="off"
else
    multicore_act_lbl="enable"
    multicore_action="on"
fi


#  Display action if elock would be triggered
if [ "$(cat /proc/ish/defaults/enable_extralocking)" = "true" ]; then
    elock_act_lbl="disable"
    elock_action="off"
else
    elock_act_lbl="enable"
    elock_action="on"
fi


# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ITEMS_DIR="$(dirname "$CURRENT_DIR")"
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="iSH-AOK"
req_win_width=33
req_win_height=13

full_path_this="$CURRENT_DIR/$(basename $0)"

login_mode="run-shell '/usr/local/bin/aok -l"
suffix=" > /dev/null' ; run-shell '$full_path_this'"

open_menu="run-shell '$ITEMS_DIR"

t_start="$(date +'%s')"

# shellcheck disable=SC2154
$TMUX_BIN display-menu \
    -T "#[align=centre] $menu_name " \
    -x "$menu_location_x" -y "$menu_location_y" \
    \
    "Back to Main menu  <==" Home "$open_menu/main.sh'" \
    "Back to Extras     <--" Left "$open_menu/extras.sh'" \
    "Back to AOK        <--" A "$open_menu/extras/aok.sh" \
    "" \
    "Current login method: $(display_login_method)" "" "" \
    " " "" "" \
    "$(disable_if_matching disabled)Disable login"    "d" "$login_mode disable $suffix" \
    "$(disable_if_matching enabled)Enable login"      "e" "$login_mode enable $suffix" \
    "$(disable_if_matching once)Single login session" "s" "$login_mode once $suffix" \
    "" \
    "$multicore_act_lbl Multicore" "m" "run-shell 'toggle_multicore $multicore_action  $suffix" \
    "$elock_act_lbl Extra locking" "e" "run-shell 'elock            $elock_action      $suffix" 

#    "" \    
#    "Help  -->" H "$open_menu/help.sh $full_path_this'"

ensure_menu_fits_on_screen
