#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling Window
#

static_content() {
    set -- \
        0.0 M Left "Back to Main menu  $nav_home" main.sh \
        0.0 M S "Split window       $nav_next" window_split.sh \
        0.0 M L "Layouts            $nav_next" layouts.sh \
        0.0 M M "Move window        $nav_next" window_move.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        1.7 C r "Rename window" "command-prompt -I '#W'  \
            -p 'New window name: ' 'rename-window %%' $mnu_runshell_reload_b" \
        1.7 C + "New window after current" "command-prompt -p \
            'Name of new window: ' 'new-window -a -n \"%%\"' $mnu_runshell_reload_b" \
        1.7 C "\>" "New window at the end" "command-prompt -p \
            'Name of new window: ' 'new-window -n \"%%\"' $mnu_runshell_reload_b" \
        1.7 C s "Display Window size" "display-message \
            'Window size: #{window_width}x#{window_height}' $mnu_runshell_reload_b" \
        0.0 S \
        1.7 C l "Last selected window" "last-window $mnu_runshell_reload_b" \
        1.7 C p "Previous window [in order]" "previous-window $mnu_runshell_reload_b" \
        1.7 C n "Next     window [in order]" "next-window $mnu_runshell_reload_b" \
        1.7 C P "Previous window with an alert" "previous-window -a $mnu_runshell_reload_b" \
        1.7 C N "Next window with an alert" "next-window -a $mnu_runshell_reload_b" \
        0.0 S \
        1.7 C x "Kill current window" "confirm-before -p \
            'kill-window #W? (y/n)' kill-window  $mnu_runshell_reload_b" \
        1.7 C o "Kill all other windows" "confirm-before -p \
            'Are you sure you want to kill all other windows? (y/n)' \
            'run-shell \"${d_scripts}/kill_other_windows.sh\"' $mnu_runshell_reload_b"

    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Handling Window"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
