#!/bin/sh
# shellcheck disable=SC2154
#
#   Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Available debug variables
#

[ "$1" = "set" ] && {
    export TMUX_MENUS_LOGGING_MINIMAL=1
    export TMUX_MENUS_NO_DISPLAY=1
    export TMUX_MENUS_PROFILING=1
    export TMUX_MENUS_HANDLER=0
}

echo "TMUX_MENUS_SHOW_CMDS=$TMUX_MENUS_SHOW_CMDS"
echo "  if 1 - Display cmd used for an action, if a prefix sequence show it"
echo
echo "TMUX_MENUS_LOGGING_MINIMAL=$TMUX_MENUS_LOGGING_MINIMAL"
echo "  If 1 - Only log errors & render times"
echo
echo "TMUX_MENUS_NO_DISPLAY=$TMUX_MENUS_NO_DISPLAY"
echo "  If 1 don't display menus, only generate them"
echo
echo "TMUX_MENUS_PROFILING=$TMUX_MENUS_PROFILING"
echo "  If 1 - profiling is used"
echo
echo "TMUX_MENUS_HANDLER=$TMUX_MENUS_HANDLER"
echo "  0 use built in menus if available, otherwise whiptail/dialog if found"
echo "  1 force whiptail"
echo "  2 force dialog"
