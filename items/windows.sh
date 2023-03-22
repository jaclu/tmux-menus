#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling Window
#
#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Handling Window"
full_path_this="$CURRENT_DIR/$(basename $0)"
req_win_width=38
req_win_height=21

reload="; run-shell \"$full_path_this\""
open_menu="run-shell '$CURRENT_DIR"

set -- "command-prompt -I \"#W\"  -p \"New window name: \"" \
        "\"rename-window '%%'\""
rename_window="$*"

new_aft="command-prompt -p \"Name of new window: \" \"new-window -a -n '%%'\""
new_at_end="command-prompt -p 'Name of new window: ' 'new-window -n \"%%\"'"
disp_size="display-message \"Window size: #{window_width}x#{window_height}\""
kill_current="confirm-before -p \"kill-window #W? (y/n)\" kill-window"

set -- "confirm-before -p" \
        "'Are you sure you want to kill all other windows? (y/n)'" \
        "'run \"${SCRIPT_DIR}/kill_other_windows.sh\"'"
kill_other="$*"

t_start="$(date +'%s')"

# shellcheck disable=SC2154
$TMUX_BIN display-menu \
        -T "#[align=centre] $menu_name   " \
        -x "$menu_location_x" -y "$menu_location_y" \
        \
        "Back to Main menu  <--" Left "$open_menu/main.sh'" \
        "Move window        -->" M "$open_menu/window_move.sh'" \
        "" \
        "<P> Rename window" , "$rename_window" \
        "    New window after current" a "$new_aft" \
        "<P> New window at the end" c "$new_at_end" \
        "    Display Window size" s "$disp_size" \
        "" \
        "<P> Last selected window" l "last-window     $reload" \
        "<P> Previous window [in order]" p "previous-window $reload" \
        "<P> Next     window (in order)" n "next-window     $reload" \
        "" \
        "Previous window with an alert" P "previous-window -a $reload" \
        "Next window with an alert" N "next-window     -a $reload" \
        "" \
        "<P> Kill current window" \& "$kill_current" \
        "    Kill all other windows" o "$kill_other" \
        "" \
        "Help  -->" H "$open_menu/help.sh $full_path_this'"

ensure_menu_fits_on_screen
