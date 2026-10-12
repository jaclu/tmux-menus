#!/bin/sh

# shellcheck disable=SC2154,SC2155
export TMUX_MENUS_LOCATION="$($TMUX_BIN show-environment -g "TMUX_MENUS_LOCATION" | cut -d= -f2)"
mh="$($TMUX_BIN show-environment -g "TMUX_MENUS_HANDLER" 2>/dev/null | cut -d= -f2)"
[ -n "$mh" ] && {
    echo "exporting TMUX_MENUS_HANDLER"
    export TMUX_MENUS_HANDLER="$mh"
}
