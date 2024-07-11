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
    menu_name="Mullvad VPN"

    # suffix=" > /dev/null' ; run-shell '$f_current_script'"

    [ -z "$(command -v mullvad)" ] && error_msg "mullvad bin not found!"

    set -- \
        0.0 M Home "'Back to Main menu  <=='" "$d_items/main.sh" \
        0.0 M Left "Back to Extras     <--" "$d_items/extras.sh" \
        0.0 S \
        0.0 C s Status "display '$(mullvad status)' $menu_reload"

    menu_generate_part 1 "$@"

    set -- \
        0.0 S \
        0.0 M H 'Help       -->' "$d_items/help.sh $f_current_script"

    # 0.0 C L "Select Location  -->" "$menu_reload'"

    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath "$(dirname -- "$(dirname -- "$(dirname -- "$0")")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

e="$?"
if [ "$e" -ne 0 ]; then
    log_it "$current_script exiting [$e]"
fi
