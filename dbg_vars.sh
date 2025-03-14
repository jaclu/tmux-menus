#!/bin/sh

[ "$1" = "set" ] && {
    export MENUS_PROFILING=1
    export TMUX_MENUS_NO_DISPLAY10 # If 1 don't display menus
    # 1 no log to stderr 2 no profiling to stderr 3 nothing to stderr
    export TMUX_MENUS_FORCE_SILENT=3
    # 0 use built in menus if available, otherwise whiptail/dialog if found
    # 1 force whiptail
    # 2 force dialog
    export TMUX_MENU_HANDLER=0
}

echo "MENUS_PROFILING: $MENUS_PROFILING"
echo "TMUX_MENUS_NO_DISPLAY: $TMUX_MENUS_NO_DISPLAY"
echo "TMUX_MENUS_FORCE_SILENT: $TMUX_MENUS_FORCE_SILENT"
echo "TMUX_MENU_HANDLER: $TMUX_MENU_HANDLER"
