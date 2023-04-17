#!/bin/sh
#
#   Copyright (c) 2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Directly control iSH-AOK
#

# Global check exclude
# shellcheck disable=SC2034,SC2154

disable_if_matching() {
    [ "$1" = "$current_login_method" ] && echo "-"
}

is_aok_kernel() {
    grep -qi aok /proc/ish/version 2>/dev/null
}

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
ITEMS_DIR="$(dirname "$CURRENT_DIR")"
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/dialog_handling.sh"

#  For items only available if kernel is AOK
if is_aok_kernel; then
    aok_kernel=""
else
    aok_kernel="-"
fi

#  shellcheck disable=SC2010
if ls -l /bin/login | grep -q login.loop; then
    current_login_method="enabled"
elif ls -l /bin/login | grep -q login.once; then
    current_login_method="once"
else
    current_login_method="disabled"
fi

if [ "$(cat /proc/ish/defaults/enable_multicore 2>/dev/null)" = "true" ]; then
    multicore_act_lbl="disable"
    multicore_action="off"
else
    multicore_act_lbl="enable"
    multicore_action="on"
fi

#  Display action if elock would be triggered
if [ "$(cat /proc/ish/defaults/enable_extralocking 2>/dev/null)" = "true" ]; then
    elock_act_lbl="disable"
    elock_action="off"
else
    elock_act_lbl="enable"
    elock_action="on"
fi

login_mode="'/usr/local/bin/aok -l"
suffix=" > /dev/null ; $current_script"

menu_name="AOK FS tools"

set -- \
    0.0 M Home "Back to Main menu  <==" "$ITEMS_DIR/main.sh" \
    0.0 M Left "Back to Extras     <--" "$ITEMS_DIR/extras.sh" \
    0.0 S \
    0.0 T "-Current login method: $current_login_method" \
    0.0 T "- " \
    0.0 E d "$(disable_if_matching disabled)Disable login" "$login_mode disable $suffix" \
    0.0 E e "$(disable_if_matching enabled)Enable login" "$login_mode enable $suffix" \
    0.0 E s "$(disable_if_matching once)Single login session" "$login_mode once $suffix" \
    0.0 S \
    0.0 T "= Only for iSH-AOK kernel =" \
    0.0 T "  kernel tweaks" "" "" \
    0.0 S \
    0.0 E m "$aok_kernel$multicore_act_lbl Multicore" "toggle_multicore $multicore_action $suffix" \
    0.0 E l "$aok_kernel$elock_act_lbl extra Locking" "elock $elock_action $suffix" \
    0.0 S \
    0.0 M H "Help  -->" "$ITEMS_DIR/help.sh $current_script'"

#
#  Doesnt work yet, needs to be investigated, seems set-timezone can't
#  access full screen from within menus
#
# 0.0 E t "set Time zone" "/usr/local/bin/set-timezone $suffix" \
# "" \

req_win_width=35
req_win_height=18

parse_menu "$@"
