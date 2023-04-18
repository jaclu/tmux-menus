#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Configure mullvad VPN
#

# Global check exclude
# shellcheck disable=SC2034,SC2154

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
ITEMS_DIR="$(dirname "$CURRENT_DIR")"
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/dialog_handling.sh"

suffix=" > /dev/null' ; run-shell '$current_script'"

if [ -z "$(command -v mullvad)" ]; then
    $TMUX_BIN display "mullvad bin not found!"
    exit 1
fi

if [ "$(mullvad lan get | awk 'NF>1{print $NF}')" = "allow" ]; then
    lan_label="Disable"
    lan_cmd="block"
else
    lan_label="Enable"
    lan_cmd="allow"
fi

#
#  city and server selection not done yet..
#
#list_cities() {
#    country="$1"
#    if [ -z "$country" ]; then
#        error_msg "extras/mullvad.cities - no param!"
#    fi
#    #  List cities
#    #  mullvad relay list | grep -v "^\t\t"
#    #    Start of line - country
#    #    Indented City
#}
# list_servers() {
#     server="$1"
#     if [ -z "$server" ]; then
#         error_msg "extras/mullvad.servers - no param!"
#     fi
# }

menu_name="Mullvad VPN"

set -- \
    0.0 M Home "'Back to Main menu  <=='" "$ITEMS_DIR/main.sh" \
    0.0 M Left "Back to Extras     <--" "$ITEMS_DIR/extras.sh" \
    0.0 S \
    0.0 C s Status "display '$(mullvad status)' $menu_reload"

#  Add conditional lines
if mullvad status | grep -q Connected; then
    set -- "$@" 0.0 E d Disconnect "mullvad disconnect ; $current_script"
else
    set -- "$@" 0.0 E c Connect "mullvad connect ; $current_script"
fi

set -- "$@" \
    0.0 E l "$lan_label LAN sharing" "mullvad lan set $lan_cmd; $current_script" \
    0.0 S \
    0.0 M H 'Help       -->' "$ITEMS_DIR/help.sh $current_script"

# 0.0 C L "Select Location  -->" "$menu_reload'"

req_win_width=33
req_win_height=10

menu_parse "$@"
