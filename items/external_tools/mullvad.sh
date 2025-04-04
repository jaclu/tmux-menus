#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
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
        set -- 0.0 E d Disconnect "mullvad disconnect ; $0"
    else
        set -- 0.0 E c Connect "mullvad connect ; $0"
    fi

    set -- "$@" \
        0.0 E l "$lan_label LAN sharing" "mullvad lan set $lan_cmd; $0"

    menu_generate_part 4 "$@"
}

static_content() {

    # suffix=" > /dev/null' ; run-shell '$0'"

    [ -z "$(command -v mullvad)" ] && error_msg_safe "mullvad bin not found!"

    # By using '' this will not be processed as the string is defined.
    # it will be  executed when it is displayed.
    # shellcheck disable=SC2016
    mulv_status_chk='Mullvad status: $(mullvad status | head -n 1)'
    set -- \
        0.0 M Left "Back to Extras     $nav_prev" extras.sh \
        0.0 M Home "'Back to Main menu  $nav_home'" main.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        0.0 C s Status "display '$mulv_status_chk' $menu_reload"

    menu_generate_part 3 "$@"
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
