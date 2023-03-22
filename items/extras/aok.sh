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

disable_if_matching() {
    [ "$1" = "$current_login_method" ] && echo "-"
}

is_aok_kernel() {
    grep -qi aok /proc/ish/version 2>/dev/null
}

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ITEMS_DIR="$(dirname "$CURRENT_DIR")"
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="AOK"
full_path_this="$CURRENT_DIR/$(basename $0)"
req_win_width=33
req_win_height=13

#  For items only available if kernel is AOK
if is_aok_kernel; then
    aok_kernel=""
else
    aok_kernel="-"
fi

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

open_menu="run-shell '$ITEMS_DIR"
login_mode="run-shell '/usr/local/bin/aok -l"
suffix=" > /dev/null ; $full_path_this'"

t_start="$(date +'%s')"

# shellcheck disable=SC2154
$TMUX_BIN display-menu \
    -T "#[align=centre] $menu_name " \
    -x "$menu_location_x" -y "$menu_location_y" \
    \
    "Back to Main menu  <==" Home "$open_menu/main.sh'" \
    "Back to Extras     <--" Left "$open_menu/extras.sh'" \
    "" \
    "Current login method: $current_login_method" "" "" \
    " " "" "" \
    "$(disable_if_matching disabled)Disable login" "d" "$login_mode disable $suffix" \
    "$(disable_if_matching enabled)Enable login" "e" "$login_mode enable $suffix" \
    "$(disable_if_matching once)Single login session" "s" "$login_mode once $suffix" \
    "" \
    "set Time zone" "t" "run-shell '/usr/local/bin/set-timezone ; $full_path_this'" \
    "" \
    "${aok_kernel}= Only for iSH-AOK kernel =" "" "" \
    "$aok_kernel  kernel tweaks" "" "" \
    "$aok_kernel$multicore_act_lbl Multicore" "m" "run-shell 'toggle_multicore $multicore_action  $suffix" \
    "$aok_kernel$elock_act_lbl Extra locking" "e" "run-shell 'elock            $elock_action      $suffix" \
    \
    "" \
    "Help  -->" H "$open_menu/help.sh $full_path_this'"

ensure_menu_fits_on_screen
