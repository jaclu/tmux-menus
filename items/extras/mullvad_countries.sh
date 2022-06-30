#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.4.9 2022-06-08
#
#   Main menu, the one popping up when you hit the trigger
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ITEMS_DIR="$(dirname "$CURRENT_DIR")"
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Mullvad Select country"

req_win_width=1
req_win_height=1


this_menu="$CURRENT_DIR/mullvad.sh"
reload="; run-shell '$this_menu'"

open_menu="run-shell '$ITEMS_DIR"

prefix="run-shell 'mullvad "
suffix=" > /dev/null' ; run-shell '$this_menu'"

if [ "$(mullvad lan get | awk 'NF>1{print $NF}')" = "allow" ]; then
    lan_label="Disable"
    lan_cmd="block"
else
    lan_label="Enable"
    lan_cmd="allow"
fi


# mullvad relay set location de
# mullvad relay set location de ber



# list_countries() {
#     # List countries
#     # mullvad relay list | grep -v "^\t"
#     #mullvad relay list | grep -v "^\t"
# }



menu_items=""

menu_items="$menu_items 'Germany' 1 \"display de\""
menu_items="$menu_items 'Sweden' 2 \"display se\""


menu_items="$menu_items '' 'Help  -->'  H           \
 \"$open_menu/help.sh $CURRENT_DIR/mullvad.sh\""


t_start="$(date +'%s')"

echo $menu_items | xargs tmux display-menu -T "#[align=centre] $menu_name "  \
    -x '$menu_location_x' -y '$menu_location_y'

ensure_menu_fits_on_screen
