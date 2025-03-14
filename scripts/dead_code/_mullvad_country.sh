#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Select country for mullvad VPN
#

nav_add() {
    [ -z "$nav" ] && nav="\"\""
    nav="$nav \"$1  $nav_next\" '$2' \"$open_menu/extras/mullvad_country.sh $3\""
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Mullvad Select Country"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(dirname -- "$(realpath "$0")")")")"
# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

error_msg_safe "THIS IS NOT USED ATM!"

offset="${1:-0}" #  optional param indicating first item to display

tmux_error_handler_assign lines display -p '#{window_height}'

# shellcheck disable=SC2154
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
countries="$(mullvad relay list | grep -v "$grep_gnu" '^\t' |
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
        log_it "can't display all"
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

# obsolete usage of tmux error handler
# echo "$menu_items" | xargs old_tmux_error_handler display-menu \
#     -T "#[align=centre] $menu_name " \
#     -x "$cfg_mnu_loc_x" -y "$cfg_mnu_loc_y"

# ensure_menu_fits_on_screen
