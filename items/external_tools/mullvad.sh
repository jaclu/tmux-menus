#!/bin/sh
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Configure mullvad VPN
#

dynamic_content() {

    if [ "$(mullvad lan get | awk 'NF>1{print $NF}')" = "allow" ]; then
        lan_label="Disable"
        lan_cmd="block"
    else
        lan_label="Enable"
        lan_cmd="allow"
    fi

    #  Add conditional lines
    if mullvad status | grep -q Connected; then
        set -- 0.0 E d Disconnect "mullvad disconnect ; $f_current_script"
    else
        set -- 0.0 E c Connect "mullvad connect ; $f_current_script"
    fi

    set -- "$@" \
        0.0 E l "$lan_label LAN sharing" "mullvad lan set $lan_cmd; $f_current_script"

    menu_generate_part 2 "$@"
}

static_content() {

    # suffix=" > /dev/null' ; run-shell '$f_current_script'"

    [ -z "$(command -v mullvad)" ] && error_msg "mullvad bin not found!"

    set -- \
        0.0 M Left "Back to Extras     $nav_prev" extras.sh \
        0.0 M Home "'Back to Main menu  $nav_home'" main.sh \
        0.0 S \
        0.0 C s Status "display '$(mullvad status)' $menu_reload"

    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Mullvad VPN"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(dirname -- "$(realpath "$0")")")")"
# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
