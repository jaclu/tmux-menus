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

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

# safety check to ensure it is defined
[ -z "$TMUX_BIN" ] && echo "ERROR: kill_session_confirm.sh - TMUX_BIN is not defined!"

set -- "Only one session, you will be disconnected if you continue." \
        "Proceed? (y/n)"
prompt="$*"

$TMUX_BIN confirm-before -p "$prompt" \
        "run-shell \"$SCRIPT_DIR/kill_current_session.sh force\""
