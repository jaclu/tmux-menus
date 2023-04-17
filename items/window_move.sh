#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Move Window
#
#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/dialog_handling.sh"

common_param="choose-tree -Gw 'run-shell \"$SCRIPT_DIR/relocate_window.sh"
to_other="$common_param W M %%\"'"
link_other="$common_param W L %%\"'"

other_pane_is_marked="$(tmux display -p '#{?pane_marked_set,,-}')"

#
#  when referred, close reference with '" in order to allow extra
#  run-shell params
#

menu_name="Move Window"

# shellcheck disable=SC2154
set -- \
    0.0 M Home "Back to Main menu        <==" main.sh \
    0.0 M Left "Back to Handling Window  <--" windows.sh \
    0.0 S \
    0.0 C m "Move window to other location" "$to_other" \
    0.0 T "${other_pane_is_marked}Swap current window with window" \
    0.0 C s "$other_pane_is_marked containing marked pane" swap-window \
    0.0 C "\<" "Swap window Left" "swap-window -dt:-1 $menu_reload" \
    0.0 C "\>" "Swap window Right" "swap-window -dt:+1 $menu_reload" \
    0.0 S \
    0.0 C l "Link window to other session" "$link_other" \
    0.0 C u "Unlink window from this session" "unlink-window" \
    0.0 S \
    0.0 M H "Help, explaining move & link  -->" "$CURRENT_DIR/help_window_move.sh $current_script"

req_win_width=41
req_win_height=15

parse_menu "$@"
