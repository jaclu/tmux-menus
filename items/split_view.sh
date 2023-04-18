#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Split display
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/dialog_handling.sh"

menu_name="Split view"

#  shellcheck disable=SC2154
set -- \
    0.0 M Left "Back to Main menu  <--" main.sh \
    0.0 T "-#[align=centre,nodim]----  Split Pane  ----" \
    2.0 C l "    Left" "split-window     -hb -c '#{pane_current_path}' $menu_reload" \
    1.7 C "\%" "<P> Right" "split-window -h  -c '#{pane_current_path}' $menu_reload" \
    2.0 C a "    Above" "split-window    -vb -c '#{pane_current_path}' $menu_reload" \
    1.7 C '\"' "<P> Below" "split-window -v  -c '#{pane_current_path}' $menu_reload" \
    0.0 T "-#[align=centre,nodim]---  Split Window  ---" \
    2.4 C L "    Left" "split-window -fhb -c '#{pane_current_path}' $menu_reload" \
    2.4 C R "    Right" "split-window -fh  -c '#{pane_current_path}' $menu_reload" \
    2.4 C A "    Above" "split-window -fvb -c '#{pane_current_path}' $menu_reload" \
    2.4 C B "    Below" "split-window -fv  -c '#{pane_current_path}' $menu_reload" \
    0.0 S \
    0.0 M H "Help  -->" "$CURRENT_DIR/help_split.sh $current_script"

req_win_width=33
req_win_height=15

menu_parse "$@"
