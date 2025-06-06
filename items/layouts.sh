#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Choose layout
#

dynamic_content() {
    #
    # Since they will be overwritten on next "fresh entry" these env variables can
    # be left once this menu is done
    #
    e_prev_menu="$plugin_name-layouts-prev-menu"
    e_prev_menu_name="$plugin_name-layouts-prev-menu-name"

    if [ -n "$prev_menu" ]; then
        # Since this menu might reload itself and then using no params,
        # store them for later potential reuse
        $TMUX_BIN set-environment -g "$e_prev_menu" "$prev_menu"
        $TMUX_BIN set-environment -g "$e_prev_menu_name" "${prev_name:-Previous menu}"
    else
        prev_menu=$($TMUX_BIN show-environment -g "$e_prev_menu" 2>/dev/null |
            cut -d= -f2)
        prev_name=$($TMUX_BIN show-environment -g "$e_prev_menu_name" 2>/dev/null |
            cut -d= -f2)
    fi

    set -- 0.0 M Left "Back to $prev_name   $nav_prev" "$prev_menu"
    [ -n "$prev_menu" ] || error_msg "$rn_current_script - no previous menu param!"
    menu_generate_part 1 "$@"
}

static_content() {
    set -- \
        0.0 M Home "Back to Main menu  $nav_home" main.sh \
        2.5 M L "Border Lines" layouts_lines.sh \
        3.3 M I "Border Indicators" layouts_indicators.sh
    menu_generate_part 2 "$@"
    $cfg_display_cmds && display_commands_toggle 3

    set -- \
        0.0 S \
        0.8 C 1 "Even horizontal" "select-layout  even-horizontal  $runshell_reload_mnu" \
        0.8 C 2 "Even vertical" "select-layout    even-vertical    $runshell_reload_mnu" \
        0.9 C 3 "Main horizontal" "select-layout  main-horizontal  $runshell_reload_mnu" \
        3.5 C "\\#" "Main horizontal - mirrored" \
        "select-layout  main-horizontal-mirrored $runshell_reload_mnu" \
        0.9 C 4 "Main vertical" "select-layout    main-vertical    $runshell_reload_mnu" \
        3.5 C "\\$" "Main vertical -   mirrored" \
        "select-layout    main-vertical-mirrored  $runshell_reload_mnu" \
        1.4 C 5 "Tiled" "select-layout            tiled            $runshell_reload_mnu" \
        2.7 C e "Spread evenly" "select-layout    -E               $runshell_reload_mnu"
    menu_generate_part 4 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Layouts"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

if [ -n "$1" ]; then
    prev_menu="$(realpath "$1")"
    shift # reamiing params are prev menu name
    prev_name="$*"
fi

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
