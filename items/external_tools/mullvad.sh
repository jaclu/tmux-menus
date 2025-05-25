#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handle mullvad VPN
#

prepare_env() {
    [ "$all_helpers_sourced" = true ] && return

    # shellcheck source=/dev/null
    . "$D_TM_BASE_PATH"/scripts/helpers.sh
}

status_as_word() {
    mullvad status | head -n 1 || {
        prepare_env
        error_msg "Command failed: mullvad status"
    }
}

is_connected() {
    [ "$(status_as_word)" = "Connected" ]
}

#---------------------------------------------------------------
#
#   with cmdline options
#
#---------------------------------------------------------------

start_stop() {
    prepare_env

    if mullvad status | grep -q Connected; then
        action="disconnect"
    else
        action="connect"
    fi

    log_it "mullvad $action"
    mullvad "$action" || {
        error_msg "mullvad $action failed: $?"
    }
    return 0
}

display_status() {
    prepare_env
    tmux_error_handler display "Mullvad status: $(status_as_word)"
}

#---------------------------------------------------------------
#
#   menu definition
#
#---------------------------------------------------------------

dynamic_content() {

    if [ "$(mullvad lan get | awk 'NF>1{print $NF}')" = "allow" ]; then
        lan_label="Disable"
        lan_cmd="block"
    else
        lan_label="Enable"
        lan_cmd="allow"
    fi

    set -- \
        0.0 E l "$lan_label LAN sharing" "mullvad lan set $lan_cmd >/dev/null; $0"
    menu_generate_part 4 "$@"
}

static_content() {

    set -- \
        0.0 M Left "Back to Extras     $nav_prev" extras.sh \
        0.0 M Home "Back to Main menu  $nav_home" main.sh
    menu_generate_part 1 "$@"

    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        0.0 E s "Status" "$0 status ; $0 " \
        0.0 E t "toggle running status" "$0 toggle ; $0"
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

command -v mullvad >/dev/null || {
    prepare_env
    error_msg "Command not found: mullvad"
}

case "$1" in
toggle)
    start_stop
    exit 0
    ;;
status)
    display_status
    exit 0
    ;;
-h)
    echo "valid options: status / toggle (or none to run the menu)" >/dev/stderr
    exit 1
    ;;
*) ;;
esac

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
