#!/bin/sh
#  shellcheck disable=SC1091,SC2034,SC2154
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Directly control DropBox
#

dynamic_content() {
    . "$D_TM_SCRIPTS"/dropbox_tools.sh

    if is_dropbox_running; then
        tgl_lbl="sTop"
    else
        tgl_lbl="sTart"
    fi

    set -- \
        0.0 E t "$tgl_lbl" "$d_current_script/_dropbox_toggle.sh $menu_reload"

    menu_generate_part 2 "$@"
}

static_content() {
    menu_name="Dropbox"
    req_win_width=33
    req_win_height=9

    [ -z "$(command -v dropbox)" ] && error_msg "dropbox bin not found!"

    set -- \
        0.0 M Home "Back to Main menu  <==" "$D_TM_ITEMS/main.sh" \
        0.0 M Left "Back to Extras     <--" "$D_TM_ITEMS/extras.sh" \
        0.0 S \
        0.0 C s "Status" "display \"$(dropbox status)\" $menu_reload"

    menu_generate_part 1 "$@"

    set -- \
        0.0 S \
        0.0 M H "Help  -->" "$D_TM_ITEMS/help.sh $current_script'"

    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname "$(cd -- "$(dirname "$(dirname -- "$0")")" && pwd)")"

#  Source dialog handling script
# shellcheck disable=SC1091
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
