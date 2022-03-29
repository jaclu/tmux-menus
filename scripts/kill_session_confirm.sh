#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.2.2 2022-03-29
#
#   Called from kill_current_session.sh
#   If the question to continue is answered with y
#   It calls kill_current_session.sh with the force param
#   to avoid making the check for just one session
#

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)


tmux confirm-before -p "Only one session, you will be disconnected if you continue. Proceed? (y/n)" "run \"$CURRENT_DIR/kill_current_session.sh force\""
