#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.2.2 2022-03-29
#
#   Displays list of clients and the list of available actions.
#

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

RESOURCES_DIR="$(dirname "$CURRENT_DIR")/resources"


tmux new-window -a -n 'manage clients'
tmux send-keys "less $RESOURCES_DIR/session_management_help.txt" Enter
tmux split-window -v -l 33%
tmux choose-client 'kill-window'

