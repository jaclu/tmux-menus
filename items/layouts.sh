#!/bin/sh
#
#   Copyright (c) 2022-2026: Jacob.Lundqvist@gmail.com
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
    # e_prev_menu_name="$plugin_name-layouts-prev-menu-name"

    if [ -n "$prev_menu" ]; then
        # Since this menu might reload itself and then using no params,
        # store them for later potential reuse
        $TMUX_BIN set-environment "$e_prev_menu" "$prev_menu"
        # $TMUX_BIN set-environment "$e_prev_menu_name" "${prev_name:-Previous menu}"
    else
        if tmux_vers_check 1.7; then
            prev_menu=$($TMUX_BIN show-environment "$e_prev_menu" | cut -d= -f2)
            # prev_name=$($TMUX_BIN show-environment "$e_prev_menu_name" | cut -d= -f2)
        else
            # doesn't support variable name for show-environment - use grep
            prev_menu=$($TMUX_BIN show-environment | grep "$e_prev_menu" | cut -d= -f2)
            # prev_name=$($TMUX_BIN show-environment | grep "$e_prev_menu_name" | cut -d= -f2)
        fi
    fi
    # check this late since it might have been manually assigned above
    [ -n "$prev_menu" ] || error_msg "$0 - no previous menu parameter given"

    set -- 0.0 M Left "Back to Previous    $nav_prev" "$prev_menu"
    menu_generate_part 1 "$@"
}

static_content() {
    set -- \
        0.0 M Home "Main Menu           $nav_home" "$cfg_main_menu" \
        2.3 M B "Pane Borders        $nav_next" layouts_pane_borders.sh \
        3.3 M I "Border Indicator    $nav_next" layouts_indicators.sh \
        3.6 M S "Scroll Bars         $nav_next" layouts_scrollbars.sh
    menu_generate_part 2 "$@"
    display_commands_toggle 3

    set -- \
        0.0 S \
        0.8 C 1 "Even horizontal" "select-layout  even-horizontal  $runshell_reload_mnu" \
        0.8 C 2 "Even vertical" "select-layout    even-vertical    $runshell_reload_mnu" \
        0.9 C 3 "Main horizontal" "select-layout  main-horizontal  $runshell_reload_mnu" \
        0.9 C 4 "Main vertical" "select-layout    main-vertical    $runshell_reload_mnu" \
        1.4 C 5 "Tiled" "select-layout            tiled            $runshell_reload_mnu" \
        3.5 C 6 "Main horizontal - mirrored" \
        "select-layout  main-horizontal-mirrored $runshell_reload_mnu" \
        3.5 C 7 "Main vertical -   mirrored" \
        "select-layout    main-vertical-mirrored  $runshell_reload_mnu" \
        2.7 C e "Spread evenly" "select-layout    -E               $runshell_reload_mnu" \
        0.0 S \
        0.0 C p "Previous layout" "previous-layout  $runshell_reload_mnu" \
        0.0 C n "Next     layout" "next-layout  $runshell_reload_mnu"
    menu_generate_part 4 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Layouts"

prev_menu="$1"

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh
