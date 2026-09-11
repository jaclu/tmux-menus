#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Place floating pane to pre-determined locations of window
#
#   Placement keys (q,w,e,a,s,d,z,x,c) centered on s, left-hand keyboard cluster.
#   Avoids numpad 5-centered logic which fails for keyboards without numpad.
#
#   The version next-3.8 is handled as 3.7z in order to not match 3.8
#   until it is released, so the below 3.7z will be replaced with 3.8 once
#   it is released
#

dynamic_content() {
    #
    # menu_idx used, empty if no floating pane is present:
    #  4 items for moving prev/next
    #
    if [ -n "$other_floating_panes" ]; then
        _fps="$d_scripts/floating_pane_switch.sh"
        set -- \
            3.7 E p "Previous" "$_fps  previous \; $0" \
            3.7 E n "Next" "$_fps  next \; $0"

    else
        set -- 0 D
    fi
    menu_generate_part 4 "$@"
}

static_content() {
    _rrm="$runshell_reload_mnu"

    set -- \
        0.0 M Left "Back to Previous  $nav_prev" floating_pane.sh \
        0.0 M Home "Back to Main      $nav_home" "$cfg_main_menu" \
        0.0 M H "Help              $nav_next" \
        "$d_help/h_floating_placement.sh $0"
    menu_generate_part 1 "$@"
    display_commands_toggle 2

    set -- \
        0.0 S \
        3.7 C N "New" \
        "new-pane -c \"#{pane_current_path}\" $runshell_sleep_reload_mnu"
    menu_generate_part 3 "$@"

    set -- \
        0.0 S \
        3.7z C q "Place top-left" "move-pane -P top-left $_rrm" \
        3.7z C w "Place top-centre" "move-pane -P top-centre $_rrm" \
        3.7z C e "Place top-right" "move-pane -P top-right $_rrm" \
        3.7z C a "Place centre-left" "move-pane -P centre-left $_rrm" \
        3.7z C s "Place centre" "move-pane -P centre $_rrm" \
        3.7z C d "Place centre-right" "move-pane -P centre-right $_rrm" \
        3.7z C z "Place bottom-left" "move-pane -P bottom-left $_rrm" \
        3.7z C x "Place bottom-centre" "move-pane -P bottom-centre $_rrm" \
        3.7z C c "Place bottom-right" "move-pane -P bottom-right $_rrm" \
        0.0 S \
        1.8 C K "${cfg_danger_zone}Kill current" "confirm-before -p \
        'kill-pane #T (#P)? (y/n)' kill-pane $runshell_reload_mnu"
    menu_generate_part 5 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Floating Pane - Placement"
menu_min_vers=3.7z

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/.." && pwd)

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/helpers_floating_pane.sh
floating_pane_focus

if [ "$current_pane_is_floating" = 1 ]; then
    # Since this will only be used if a floater is focused, full caching can be
    # implemented

    # shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
    . "$D_TM_BASE_PATH"/scripts/menu_handling.sh
else
    # Jump back to floating pane overview menu, it can handle the case of no
    # visible floating panes
    "$D_TM_BASE_PATH"/items/floating_pane.sh
fi
