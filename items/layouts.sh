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
        0.0 M Left "Back to Main menu  $nav_home" main.sh \
        3.2 M L "Border Lines" layouts_lines.sh \
        3.3 M I "Border Indicators" layouts_indicators.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        1.0 C 1 "Even horizontal" "select-layout even-horizontal $menu_reload" \
        1.0 C 2 "Even vertical" "select-layout even-vertical   $menu_reload" \
        1.0 C 3 "Main horizontal" "select-layout main-horizontal $menu_reload" \
        1.0 C 4 "Main vertical" "select-layout main-vertical   $menu_reload" \
        1.4 C 5 "Tiled" "select-layout tiled           $menu_reload" \
        2.7 C e "Spread evenly" "select-layout -E  $menu_reload"

    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Layouts"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
