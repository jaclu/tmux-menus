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

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ITEMS_DIR="$(dirname "$CURRENT_DIR")"
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="iSH-AOK"
req_win_width=33
req_win_height=13

login_mode="run-shell '/usr/local/bin/aok -l"
suffix=" > /dev/null' ; run-shell '$this_menu'"

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
    "Current login method: $(display_login_method)" \
    "Disable login" "d" "$login_mode disable $suffix" \
    "Enable login" "l" "$login_mode enable $suffix" \
    "Single login session" "s" "$login_mode once $suffix" \
    "" \
    "Help  -->" H "$open_menu/help.sh $CURRENT_DIR/spotify.sh'"

ensure_menu_fits_on_screen
