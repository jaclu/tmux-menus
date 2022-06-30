#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.0.0 2022-06-30
#
#   Select country for mullvad VPN
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ITEMS_DIR="$(dirname "$CURRENT_DIR")"
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

req_win_width=28
req_win_height=9

menu_name="Mullvad Select Country"

open_menu="run-shell '$ITEMS_DIR"

lines="$(tmux display -p '#{window_height}')"
display_items=$(( lines - 7 ))
if [ "$display_items" -lt 1 ]; then
    ensure_menu_fits_on_screen
    exit 1
fi


#
#  Cmd line params to limit list size, optional parameters are
#  offset and max display
#
offset="${1:-0}"


nav_add() {
    [ -z "$nav" ] && nav="\"\""
    nav="$nav \"$1\" '$2' \"$open_menu/extras/mullvad_country.sh $3\""
}


if [ "$offset" -gt 0 ]; then
    new_offset=$(( offset - display_items ))
    [ "$new_offset" -lt 0 ] && new_offset=0
    nav_add "Back  -->" B $new_offset
fi


idx=0
max_item=$(( offset + display_items ))
available_short_cuts="01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
countries="$(mullvad relay list | grep -v -e "^\t" -e "^$" | \
             awk '{printf "%s|",$0}')"
#
#  BSD & GNU grep regexp differs...
#
if grep -V | grep -q BSD ; then
    grep_gnu=""
else
    grep_gnu="-P"
fi
countries="$(mullvad relay list | grep -v $grep_gnu '^\t' | grep -v '^$' | awk '{printf "%s|",$0}')"

#  shellcheck disable=SC2089
menu_items="'Back to Main menu'  Home  \"$open_menu/main.sh'\" 'Back to Mullvad'  Left  \"$open_menu/extras/mullvad.sh'\" \"\" "
while true; do
    country="${countries%%|*}"
    countries="${countries#*|}"

    [ -z "$country" ] && break  #  skipping ending blank line

    #
    #  Limit list size if screen is to small to handle entire list
    #
    if [ "$idx" -ge $max_item ]; then
        log_it "cant display all"
        nav_add "Forward  -->" F $idx
        break
    fi

    idx=$(( idx + 1 ))
    [ "$idx" -le "$offset" ] && continue

    country_code="$(echo "$country" | cut -d\( -f 2 | sed s/\)//)"

    short_cut="$(echo $available_short_cuts | cut -c1-1)"
    available_short_cuts="$(echo $available_short_cuts | cut -c2-)"


    #  Add a line to the list
    #  shellcheck disable=SC2089
    menu_items="$menu_items '$country' $short_cut \"run-shell 'mullvad relay set location $country_code > /dev/null'\""

    [ "$countries" = "$country" ] && break  # we have processed last item
done


menu_items="$menu_items $nav"



t_start="$(date +'%s')"

#  shellcheck disable=SC2086,SC2090,SC2154
echo $menu_items | xargs tmux display-menu -T "#[align=centre] $menu_name "  \
    -x $menu_location_x -y $menu_location_y





ensure_menu_fits_on_screen
