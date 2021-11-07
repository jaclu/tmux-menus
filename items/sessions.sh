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
#   Menu dealing with sessions
#

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


tmux display-menu  \
     -T "#[align=centre] Sessions "  \
     -x C -y C  \
     \
     "Back to main-menu"  Left  "run-shell $CURRENT_DIR/main.sh"  \
     "" \
     "<P> Rename this session"         $   "command-prompt -I \"#S\" \"rename-session -- '%%'\""  \
     "    New session"                 n  "command-prompt -p \"Name of new session: \" \"new-session -s '%%'\""  \
     "    Kill current session"        k  "run \"cut -c3- $PATH_TO_TMUX_CONF | sh -s _kill_current_session\""    \
     "" \
     "    Choose session, use arrows" ""  ""  \
     "<P>         to navigate & zoom"   s   "choose-tree -Zs"  \
     "" \
     "Help"  h  "run-shell \"$CURRENT_DIR/help.sh $CURRENT_DIR/sessions.sh\""
