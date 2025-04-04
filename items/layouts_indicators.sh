#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Choose layout
#

static_content() {
    set -- \
        0.0 M Left "Back to Layouts    $nav_prev" layouts.sh \
        0.0 M Home "Back to Main menu  $nav_home" main.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        3.3 S \
        3.3 T "-#[align=centre,nodim]pane-border-indicators" \
        3.3 C "o" "off" "set -g pane-border-indicators off    $menu_reload" \
        3.3 C "c" "colour" "set -g pane-border-indicators colour $menu_reload" \
        3.3 C "a" "arrows" "set -g pane-border-indicators arrows $menu_reload" \
        3.3 C "b" "both" "set -g pane-border-indicators both   $menu_reload"

    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Layouts - Indicators"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
