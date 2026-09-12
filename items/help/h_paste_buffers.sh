#!/bin/sh
#
#   Copyright (c) 2022-2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help regarding panes menu
#

static_content() {
    if [ -z "$prev_menu" ]; then
        error_msg "$bn_current_script was called without notice of what called it"
    fi
    set -- \
        0.0 M Left "Back to Previous  $nav_prev" "$prev_menu" \
        0.0 M Home "Back to Main      $nav_home" "$cfg_main_menu" \
        0.0 S \
        0.0 T "Tmux has its own clipboard system," \
        0.0 T "shared between all sessions/windows/panes." \
        0.0 T "" \
        0.0 T "To integrate this clipboard with that" \
        0.0 T "of the OS, this might need configuration" \
        0.0 T "in tmux.conf depending on what OS" \
        0.0 T "and terminal is being used." \
        0.0 S \
        0.0 T "If nothing has been copied to a tmux buffer" \
        0.0 T "actions will return immediately."
    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Help Paste buffers"

[ -n "$1" ] && prev_menu="$(realpath "$1")"

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/../.." && pwd)

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/menu_handling.sh
