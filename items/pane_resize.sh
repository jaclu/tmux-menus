#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.2.7  2022-04-16
#
#   Resize a pane
#
#   Types of menu item lines.
#
#   1) An item leading to an action
#          "Description" "In-menu key" "Action taken when it is triggered"
#
#   2) Just a line of text
#      You must supply two empty strings, in order for the
#      menu logic to interpret it as a full menu line item.
#          "Some text to display" "" ""
#
#   3) Separator line
#      This is a proper graphical separator line, without any label.
#          ""
#
#   4) Labeled separator line
#      Not perfect, since you will have at least one space on each side of
#      the labeled separator line, but using something like this and carefully
#      increase the dashes until you are just below forcing the menu to just
#      grow wider, seems to be as close as it gets.
#          "#[align=centre]-----  Other stuff  -----" "" ""
#
#
#   All but the last line in the menu, needs to end with a continuation \
#   White space after this \ will cause the menu to fail!
#   For any field containing no spaces, quotes are optional.
#

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Resize Pane"
req_win_width=33
req_win_height=18


t_start="$(date +'%s')"

# shellcheck disable=SC2154
tmux display-menu  \
     -T "#[align=centre] $menu_name "  \
     -x "$menu_location_x" -y "$menu_location_y"  \
     \
     "Back to Main menu"      Home  "run-shell $CURRENT_DIR/main.sh"  \
     "Back to Handling Pane"  Left  "run-shell $CURRENT_DIR/panes.sh" \
     "" \
     "Specify width & height"  s  "command-prompt -p 'Pane width,Pane height' 'resize-pane -x %1 -y %2'" \
     "-#[align=centre,nodim]-------  resize by 1  ------" "" "" \
     "up     "  u  "resize-pane -U ; run-shell \"$CURRENT_DIR/pane_resize.sh\""    \
     "down   "  d  "resize-pane -D ; run-shell \"$CURRENT_DIR/pane_resize.sh\""    \
     "left   "  l  "resize-pane -L ; run-shell \"$CURRENT_DIR/pane_resize.sh\""    \
     "right  "  r  "resize-pane -R ; run-shell \"$CURRENT_DIR/pane_resize.sh\""    \
     "-#[align=centre,nodim]-------  resize by 5  ------" "" "" \
     "up     "  U  "resize-pane -U 5 ; run-shell \"$CURRENT_DIR/pane_resize.sh\""  \
     "down   "  D  "resize-pane -D 5 ; run-shell \"$CURRENT_DIR/pane_resize.sh\""  \
     "left   "  L  "resize-pane -L 5 ; run-shell \"$CURRENT_DIR/pane_resize.sh\""  \
     "right  "  R  "resize-pane -R 5 ; run-shell \"$CURRENT_DIR/pane_resize.sh\""  \
     "" \
     "Help  -->"  H  "run-shell \"$CURRENT_DIR/help.sh $CURRENT_DIR/pane_resize.sh\""


ensure_menu_fits_on_screen
