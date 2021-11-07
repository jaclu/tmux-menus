#!/usr/bin/env bash
#
#   Copyright (c) 2021: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.0 2021-11-07
#       Initial release
#
#   This is the help menu, in case you havent guessed :)
#
#   There are three types of menu item lines:
#   1) An item leading to an action
#       "Description" "in menu shortcut key" " action taken when it is triggered"
#   2) Just a line of text
#       "Some text to display" "" ""
#   3) Separator line
#       ""
#   All but the last line in the menu, needs to end with a continuation \
#    
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

previous_menu="$1"


if [ -z "$previous_menu" ]; then
    tmux display-message -d 0 "ERROR: tmux-menus:help was called without notice of what called it"
fi


tmux display-menu  \
     -T "#[align=centre] Help summary "  \
     -x C -y C  \
     \
     "Back to pevious menu"  Left  "run-shell $previous_menu"  \
     "" \
    "On options spanning multiple lines,"      "" ""  \
    "if you use Enter to select, you must be"  "" ""  \
    "on the line with the shortcut. Otherwise" "" ""  \
    "it is interperated as cancel."            "" ""  \
    "" \
    "<P> indicates this key is a deault key" "" ""  \
    "    so unless you have changed it," "" ""   \
    "    it should be possible to use" "" "" \
    "    with <prefix> directly." "" ""
