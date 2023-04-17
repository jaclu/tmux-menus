#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Called from kill_current_session.sh
#   If the question to continue is answered with y
#   It calls kill_current_session.sh with the force param
#   to avoid making the check for just one session
#
# Global check exclude, ignoring: is referenced but not assigned
# shellcheck disable=SC2154

if [ -z "$CURRENT_DIR" ] || [ -z "$SCRIPT_DIR" ]; then
        echo "ERROR: CURRENT_DIR & SCRIPT_DIR must be defined!"
        exit 1
fi

set -- "Only one session, you will be disconnected if you continue." \
        "Proceed? (y/n)"
prompt="$*"

$TMUX_BIN confirm-before -p "$prompt" \
        "run-shell \"$SCRIPT_DIR/kill_current_session.sh force\""
