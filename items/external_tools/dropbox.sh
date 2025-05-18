#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Directly control DropBox
#

static_content() {

    [ -z "$(command -v dropbox)" ] && error_msg_safe "dropbox bin not found!"

    set -- \
        0.0 M Left "Back to Extras     $nav_prev" extras.sh \
        0.0 M Home "Back to Main menu  $nav_home" main.sh
    menu_generate_part 1 "$@"

    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        0.0 E s "Status" "$(dirname "$0")/dropbox_check.sh status ; $0" \
        0.0 E t "toggle running status" "$(dirname "$0")/dropbox_check.sh toggle ; $0"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Dropbox"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(dirname -- "$(realpath "$0")")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
