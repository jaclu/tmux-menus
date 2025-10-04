#!/bin/sh
#
#   Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Lists all sessions, if popups are available it will be used
#

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd -- "$(dirname -- "$0")/.." && pwd)

. "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh

cmd="$TMUX_BIN list-sessions"
if tmux_vers_check 3.2; then
    $TMUX_BIN display-popup -w 95% -h 80% -T ' All sessions ' \
        "$cmd ; printf '\nPress Escape / Ctrl-C to close this Popup\n'"
    [ -n "$1" ] && $1 # re-display previous menu
else
    $TMUX_BIN new-window -n "List all sessions" \
        "$TMUX_BIN list-sessions ; printf '\nPress Ctrl-C to close this Window\n' ; sleep 3600"
fi

