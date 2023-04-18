#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling Window
#
#  shellcheck disable=SC1091,SC2034
#  Directives for shellcheck directly after bang path are global

# shel  lcheck disable=SC1007

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

. "$SCRIPT_DIR/utils.sh"
. "$SCRIPT_DIR/dialog_handling.sh"

menu_name="Handling Window"

#  shellcheck disable=SC2154
set -- \
    0.0 M Left "Back to Main menu  <--" main.sh \
    0.0 M M "Move window        -->" window_move.sh \
    0.0 S \
    1.7 C "," "<P> Rename window" "command-prompt -I '#W'  \
        -p 'New window name: ' 'rename-window %%'" \
    1.7 C a "    New window after current" "command-prompt -p \
        'Name of new window: ' 'new-window -a -n \"%%\"'" \
    1.7 C c "<P> New window at the end" "command-prompt -p \
        'Name of new window: ' 'new-window -n \"%%\"'" \
    1.7 C s "    Display Window size" "display-message \
        'Window size: #{window_width}x#{window_height}'" \
    0.0 S \
    1.7 C l "<P> Last selected window" "last-window     $menu_reload" \
    1.7 C p "<P> Previous window [in order]" "previous-window $menu_reload" \
    1.7 C n "<P> Next     window (in order)" "next-window     $menu_reload" \
    0.0 S \
    1.7 C P "Previous window with an alert" "previous-window -a $menu_reload" \
    1.7 C N "Next window with an alert" "next-window     -a $menu_reload" \
    0.0 S \
    1.7 C "\&" "<P> Kill current window" "confirm-before -p \
        'kill-window #W? (y/n)' kill-window" \
    1.7 C o "    Kill all other windows" "confirm-before -p \
        'Are you sure you want to kill all other windows? (y/n)' \
        'run-shell \"${SCRIPT_DIR}/kill_other_windows.sh\"'" \
    0.0 S \
    0.0 M H "Help  -->" "$CURRENT_DIR/help.sh $current_script"

req_win_width=38
req_win_height=21

menu_parse "$@"
