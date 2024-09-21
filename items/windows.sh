#!/bin/sh
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling Window
#

static_content() {
    set -- \
        0.0 M Left "Back to Main menu <--" main.sh \
        0.0 M M "Move window       -->" window_move.sh \
        0.0 S \
        1.7 C r "Rename window" "command-prompt -I '#W'  \
            -p 'New window name: ' 'rename-window %%'" \
        1.7 C + "New window after current" "command-prompt -p \
            'Name of new window: ' 'new-window -a -n \"%%\"'" \
        1.7 C "\>" "New window at the end" "command-prompt -p \
            'Name of new window: ' 'new-window -n \"%%\"'" \
        1.7 C s "Display Window size" "display-message \
            'Window size: #{window_width}x#{window_height}'" \
        0.0 S \
        1.7 C l "Last selected window" "last-window     $menu_reload" \
        1.7 C p "Previous window [in order]" "previous-window $menu_reload" \
        1.7 C n "Next     window [in order]" "next-window     $menu_reload" \
        1.7 C P "Previous window with an alert" "previous-window -a $menu_reload" \
        1.7 C N "Next window with an alert" "next-window     -a $menu_reload" \
        0.0 S \
        1.7 C x "Kill current window" "confirm-before -p \
            'kill-window #W? (y/n)' kill-window" \
        1.7 C o " Kill all other windows" "confirm-before -p \
            'Are you sure you want to kill all other windows? (y/n)' \
            'run-shell \"${d_scripts}/kill_other_windows.sh\"'" \
        0.0 S \
        0.0 M H "Help -->" "$d_items/help.sh $f_current_script"

    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Handling Window"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

e="$?"
if [ "$e" -ne 0 ]; then
    log_it "$current_script exiting [$e]"
fi
