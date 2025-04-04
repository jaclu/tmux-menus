#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Directly control DropBox
#

dynamic_content() {
    # shellcheck source=scripts/dropbox_tools.sh
    . "$d_scripts"/dropbox_tools.sh

    if is_dropbox_running; then
        tgl_lbl="sTop"
    else
        tgl_lbl="sTart"
    fi

    # shellcheck disable=SC2154
    set -- \
        0.0 E t "$tgl_lbl" "$d_current_script/_dropbox_toggle.sh $menu_reload"

    menu_generate_part 4 "$@"
}

static_content() {

    [ -z "$(command -v dropbox)" ] && error_msg_safe "dropbox bin not found!"

    log_it "><> dropbox.sh menu_reload [$menu_reload]"
    set -- \
        0.0 M Left "Back to Extras     $nav_prev" extras.sh \
        0.0 M Home "Back to Main menu  $nav_home" main.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        0.0 C s "Status" "display \"$(dropbox status)\" $menu_reload"
    # display \"hepp\" \; run-shell /home/jaclu/git_repos/mine/tmux-menus/items/external_tools/dropbox.sh
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
