#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.1.0 2022-07-28
#
#   Configure mullvad VPN
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ITEMS_DIR="$(dirname "$CURRENT_DIR")"
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Mullvad VPN"
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

list_cities() {
    country="$1"
    if [ -z "$country" ]; then
        error_msg "extras/mullvad.cities - no param!"
    fi
    #  List cities
    #  mullvad relay list | grep -v "^\t\t"
    #    Start of line - country
    #    Indented City
}

# list_servers() {
#     server="$1"
#     if [ -z "$server" ]; then
#         error_msg "extras/mullvad.servers - no param!"
#     fi
# }


t_start="$(date +'%s')"

# shellcheck disable=SC2154
tmux display-menu                                                           \
    -T "#[align=centre] $menu_name "                                        \
    -x "$menu_location_x" -y "$menu_location_y"                             \
                                                                            \
    "Back to Main menu"  Home  "$open_menu/main.sh'"                        \
    "Back to Extras"     Left  "$open_menu/extras.sh'"                      \
    ""                                                                      \
    "Status"                  s  "display \"$(mullvad status)\" ;           \
                                    run-shell '$this_menu'"                 \
    "Connect"                 c  "$prefix connect $suffix"                  \
    "Disconnect"              d  "$prefix disconnect $suffix"               \
    "$lan_label LAN sharing"  l  "$prefix lan set $lan_cmd $suffix"         \
    "Select Location  -->"     L  "$open_menu/extras/mullvad_country.sh'"



ensure_menu_fits_on_screen
