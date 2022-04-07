#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.0.0 2022-04-03
#
#   Select and modify paste buffers
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


# shellcheck disable=SC2154
tmux display-menu  \
     -T "#[align=centre] Paste buffers "  \
     -x "$menu_location_x" -y "$menu_location_y"  \
     \
     "Back to Main menu"      Home  "run-shell $CURRENT_DIR/main.sh"  \
     "Back to Handling Pane"  Left  "run-shell $CURRENT_DIR/panes.sh" \
     "" \
     "     ========  Commands  ========"        "" "" \
     "    Enter Paste selected buffer"           "" "" \
     "    Up    Select previous buffer"          "" "" \
     "    Down  Select next buffer"              "" "" \
     "    C-s   Search by name or content"       "" "" \
     "    n     Repeat last search"              "" "" \
     "    t     Toggle if buffer is tagged"      "" "" \
     "    T     Tag no buffers"                  "" "" \
     "    C-t   Tag all buffers"                 "" "" \
     "    p     Paste selected buffer"           "" "" \
     "    P     Paste tagged buffers"            "" "" \
     "    d     Delete selected buffer"          "" "" \
     "    D     Delete tagged buffers"           "" "" \
     "    e     Open the buffer in an editor"    "" "" \
     "    f     Enter a format to filter items"  "" "" \
     "    O     Change sort field"               "" "" \
     "    r     Reverse sort order"              "" "" \
     "    v     Toggle preview"                  "" "" \
     "    q     Exit mode"                       "" "" \
     "<P>"  =  "choose-buffer -Z"  \
     "" \
     "Help  -->"  H  "run-shell \"$CURRENT_DIR/help.sh $CURRENT_DIR/pane_buffers.sh\""