#!/bin/sh
#  shellcheck disable=SC2034,SC2154
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Configure mullvad VPN
#

extras_dir=$(cd -- "$(dirname -- "$0")" && pwd)
#  Should point to tmux-menux plugin
D_TM_BASE_PATH="$(dirname "$(dirname "$(cd -- "$(dirname -- "$0")" && pwd)")")"

#  Source dialog handling script
# shellcheck disable=SC1091
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

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
    0.0 M Home "'Back to Main menu  <=='" "$D_TM_ITEMS/main.sh" \
    0.0 M Left "Back to Extras     <--" "$D_TM_ITEMS/extras.sh" \
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
    0.0 M H 'Help       -->' "$D_TM_ITEMS/help.sh $current_script"

# 0.0 C L "Select Location  -->" "$menu_reload'"

req_win_width=33
req_win_height=10

menu_parse "$@"
