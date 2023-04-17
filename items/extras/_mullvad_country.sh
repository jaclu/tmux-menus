#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Select country for mullvad VPN
#

# Global check exclude
# shellcheck disable=SC2034,SC2154

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
ITEMS_DIR="$(dirname "$CURRENT_DIR")"
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/dialog_handling.sh"

nav_add() {
    [ -z "$nav" ] && nav="\"\""
    nav="$nav \"$1  -->\" '$2' \"$open_menu/extras/mullvad_country.sh $3\""
}

menu_name="Mullvad Select Country"
req_win_width=28
req_win_height=9

offset="${1:-0}" #  optional param indicating first item to display

lines="$($TMUX_BIN display -p '#{window_height}')"
display_items=$((lines - 7))
max_item=$((offset + display_items))

if [ "$display_items" -lt 1 ]; then
    #  Screen not high enough to display even one item from the list
    #  Abort with error message about insufficient screen size
    ensure_menu_fits_on_screen
    exit 1
fi

if [ "$offset" -gt 0 ]; then
    previous_page=$((offset - display_items))
    [ "$previous_page" -lt 0 ] && previous_page=0
    nav_add "Back" B "$previous_page"
fi

#  shellcheck disable=SC2089
menu_items="'Back to Main menu'  Home  \"$open_menu/main.sh'\" \
    'Back to Mullvad'  Left  \"$open_menu/extras/mullvad.sh'\" \"\" "

#
#  BSD & GNU grep regexp differs...
#
if grep -V | grep -q BSD; then
    grep_gnu=""
else
    grep_gnu="-P"
fi
# shellcheck disable=SC2248
countries="$(mullvad relay list | grep -v $grep_gnu '^\t' |
    grep -v '^$' | awk '{printf "%s|",$0}')"

s="1234567890abcdefghijklmnopqrstuvwxyz"
s="${s}ACDEGHIJKLMNOPQRSTUVWXYZ"
available_keys="${s}~!@#$%^&*()-_=+[{]}:\|,<.>/?"

idx=0
while true; do
    country="${countries%%|*}"
    countries="${countries#*|}"

    [ -z "$country" ] && break #  skpp empty lines

    #
    #  Limit list size if screen is to small to handle entire list
    #
    if [ "$idx" -ge "$max_item" ]; then
        log_it "cant display all"
        nav_add "Forward" F "$idx"
        break
    fi

    idx=$((idx + 1))

    #  loop until we come to first item to display
    [ "$idx" -le "$offset" ] && continue

    country_code="$(echo "$country" | cut -d\( -f 2 | sed s/\)//)"

    #  Pick the next available shortcut-key, then pop it of the list
    key="$(echo "$available_keys" | cut -c1-1)"
    available_keys="$(echo "$available_keys" | cut -c2-)"

    #  Add a line to the menu
    #  shellcheck disable=SC2089
    menu_items="$menu_items '$country' '$key' \
        \"run-shell 'mullvad relay set location $country_code > /dev/null'\""

    [ "$countries" = "$country" ] && break # we have processed last item

    if [ -z "$available_keys" ]; then
        #
        #  Next iteration will fail due to having run out of keys,
        #  shouldn't happen. When setting this up there were plenty of spare
        #  keys. If this becomes an issue at some point, one workaround is
        #  to simply not use short-cut keys.
        #  Safety workaround for now, repeat usage of '?', will look slightly
        #  confusing but will not break anything (as-of 3.3a)
        #
        available_keys='?'
    fi
done

menu_items="$menu_items $nav"

#  shellcheck disable=SC2086,SC2090,SC2154
echo $menu_items | xargs $TMUX_BIN display-menu \
    -T "#[align=centre] $menu_name " \
    -x $menu_location_x -y $menu_location_y

ensure_menu_fits_on_screen
