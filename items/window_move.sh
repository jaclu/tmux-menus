#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.3.6  2022-06-08
#
#   Move Window
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Move Window"
req_win_width=41
req_win_height=15


this_menu="$CURRENT_DIR/window_move.sh"
reload="; run-shell \"$this_menu\""

common_param="choose-tree -Gw 'run-shell \"$SCRIPT_DIR/relocate_window.sh"
to_other="$common_param W M %%\"'"
link_other="$common_param W L %%\"'"
#
#  when referred, close reference with '" in order to allow extra
#  run-shell params
#
open_menu="run-shell '$CURRENT_DIR"


t_start="$(date +'%s')"

# shellcheck disable=SC2154
tmux display-menu                                                           \
    -T "#[align=centre] $menu_name "                                        \
    -x "$menu_location_x" -y "$menu_location_y"                             \
                                                                            \
    "Back to Main menu"        Home  "$open_menu/main.sh'"                  \
    "Back to Handling Window"  Left  "$open_menu/windows.sh'"               \
    ""                                                                      \
    "Move window to other location"      m  "$to_other"                     \
    "#{?pane_marked_set,-#[nodim],-}Swap current window with window"        \
    "" ""                                                                   \
    "#{?pane_marked_set,,-} containing marked pane"                         \
                                         s  swap-window                     \
    "Swap window Left"                  \<  "swap-window -dt:-1 $reload"    \
    "Swap window Right"                 \>  "swap-window -dt:+1 $reload"    \
    ""                                                                      \
    "Link window to other session"       l  "$link_other"                   \
    "Unlink window from this session"    u  "unlink-window"                 \
    ""                                                                      \
    "Help, explaining move & link  -->"                                     \
        H  "$open_menu/help_window_move.sh $this_menu'"

ensure_menu_fits_on_screen
