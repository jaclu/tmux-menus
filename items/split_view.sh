#!/usr/bin/env bash
#
#   Copyright (c) 2021: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.1.1 2021-12-03
#
#   menu dealing with panes
#
#   There are three types of menu item lines:
#   1) An item leading to an action
#       "Description" "in menu shortcut key" " action taken when it is triggered"
#   2) Just a line of text
#       "Some text to display" "" ""
#   3) Separator line
#       ""
#   All but the last line in the menu, needs to end with a continuation \
#   Whitespace after thhis \ will fail the menu!
#

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

source "$SCRIPT_DIR/utils.sh"


tmux display-menu  \
     -T "#[align=centre] Split view "  \
     -x $menu_location_x -y $menu_location_y \
     \
     "Back to main-menu"       Left  "run-shell $CURRENT_DIR/main.sh"  \
     "#[align=centre]---  Split Pane  ---" "" "" \
     "Left"  l "split-window -hb  -c '#{pane_current_path}'" \
     "Right" r "split-window -h -c '#{pane_current_path}'" \
     "Above" a "split-window -vb -c '#{pane_current_path}'" \
     "Below" b "split-window -v  -c '#{pane_current_path}'" \
     "#[align=centre]--  Split Window  --" "" "" \
     "Left"  L "split-window -fhb -c '#{pane_current_path}'" \
     "Right" R "split-window -fh  -c '#{pane_current_path}'" \
     "Above" A "split-window -fvb -c '#{pane_current_path}'" \
     "Below" B "split-window -fv  -c '#{pane_current_path}'" \
     "" \
     "Help"  h  "run-shell \"$CURRENT_DIR/help_split.sh $CURRENT_DIR/pane_splitting.sh\""
