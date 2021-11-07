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
#   Kills current session. If this is the only session, it
#   first calls kill_session_confirm.sh where user can confirm
#   if this should still happen, since it will terminate the tmux server.
#

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

force_directive="force"


if [ "$1" != "$force_directive" ]; then
    ses_count="$(tmux list-sessions | wc -l)"
    if [ "$ses_count" -eq 1 ]; then
	$CURRENT_DIR/kill_session_confirm.sh
	exit 0
    fi
fi

ses_to_go="$(tmux display-message -p '#{session_id}')"

if [ -z "$ses_to_go" ]; then
   exit 0
fi



#  switch to random next session
tmux switch-client -n &

sleep 2

tmux kill-session -t "$ses_to_go"
 
