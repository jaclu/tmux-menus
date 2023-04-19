#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Resize a pane
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/dialog_handling.sh"

menu_name="Resize Pane"

#  shellcheck disable=SC2154
set -- \
    0.0 M Home "Back to Main menu      <==" main.sh \
    0.0 M Left "Back to Handling Pane  <--" panes.sh \
    0.0 S \
    1.7 C s "Specify width & height" "command-prompt -p \
        'Pane width,Pane height' 'resize-pane -x %1 -y %2'" \
    0.0 T "-#[align=centre,nodim]-------  resize by 1  ------" \
    1.7 C u "up     " "resize-pane -U $menu_reload" \
    1.7 C d "down   " "resize-pane -D $menu_reload" \
    1.7 C l "left   " "resize-pane -L $menu_reload" \
    1.7 C r "right  " "resize-pane -R $menu_reload" \
    0.0 T "-#[align=centre,nodim]-------  resize by 5  ------" \
    1.7 C U "up" "resize-pane -U 5 $menu_reload" \
    1.7 C D "down" "resize-pane -D 5 $menu_reload" \
    1.7 C L "left" "resize-pane -L 5 $menu_reload" \
    1.7 C R "right" "resize-pane -R 5 $menu_reload" \
    0.0 S \
    0.0 M H "Help  -->" "$CURRENT_DIR/help.sh $current_script"

req_win_width=37
req_win_height=18

menu_parse "$@"
