#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Define how pane lines should be displayed
#

static_content() {
    set -- \
        0.0 M Left "Back to Layouts    $nav_prev" layouts.sh \
        0.0 M Home "Back to Main menu  $nav_home" main.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    _c="set-option -w pane-scrollbars"
    set -- \
        0.0 S \
        3.6 C 0 "Off" "$_c  off  $runshell_reload_mnu" \
        3.6 C m "Modal (only in scrollback)" "$_c  modal  $runshell_reload_mnu" \
        3.6 C 1 "On" "$_c   on   $runshell_reload_mnu"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Layouts - Scrollbars"
menu_min_vers=3.6

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd -- "$(dirname -- "$0")/.." && pwd)

. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
