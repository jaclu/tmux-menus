#!/bin/sh
# shellcheck disable=SC2154  # these variables would be defined in env
#
#   Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Available debug variables
#

if [ "$1" = "clear" ]; then
    unset TMUX_MENUS_LOGGING_MINIMAL
    unset TMUX_MENUS_NO_DISPLAY
    unset TMUX_MENUS_PROFILING
    unset TMUX_MENUS_HANDLER
elif [ "$1" = "set" ]; then
    # Set current default dbg env
    export TMUX_MENUS_PROFILING=1
    export TMUX_MENUS_LOGGING_MINIMAL=1
fi

echo "TMUX_MENUS_LOGGING_MINIMAL $TMUX_MENUS_LOGGING_MINIMAL"
echo "  1 Only log errors & render times"
echo "  2 no logging at all"
echo
echo "TMUX_MENUS_NO_DISPLAY $TMUX_MENUS_NO_DISPLAY"
echo "  1 don't display menus, only generate them"
echo
echo "TMUX_MENUS_PROFILING $TMUX_MENUS_PROFILING"
echo "  1 profiling is used"
echo
echo "TMUX_MENUS_HANDLER $TMUX_MENUS_HANDLER"
echo "  0 use built in menus if available, otherwise whiptail/dialog if found"
echo "  1 force whiptail"
echo "  2 force dialog"
echo
echo "In most cases they need be set with export, to get tmux to pick up on them"
echo "Example: export TMUX_MENUS_HANDLER=1"
echo
echo "To clear all debug variables, source this with option: clear"
echo "  . $0 clear"
echo
