#!/usr/bin/env bash
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: X.X 2022-01-13
#
#   Displays list of clients and the list of available actions.
#   

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

RESOURCES_DIR="$(dirname "$CURRENT_DIR")/resources"


tmux new-window -a -n 'manage clients'
tmux send-keys "less $RESOURCES_DIR/session_management_help.txt" Enter
tmux split-window -v -l 33%
tmux choose-client 'kill-window'

