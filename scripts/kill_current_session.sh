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
#   if this should still happen, since it will terminate the session
#

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

force_directive="force"

echo "$(date) param 1 [$1]" >> /tmp/session_kill.log

if [ "$1" != "$force_directive" ]; then
    echo "$(date) not called with force" >> /tmp/session_kill.log
    ses_count="$(tmux list-sessions | wc -l)"
    if [ "$ses_count" -eq 1 ]; then
	$CURRENT_DIR/kill_session_confirm.sh
	exit 0
	echo" $(date) ERROR: continued after confirm exit!" >> /tmp/session_kill.log
    fi
fi

ses_to_go="$(tmux display-message -p '#S')"

if [ -z "$ses_to_go" ]; then
   echo "$(date) ses_to_go empty" >> /tmp/session_kill.log
   exit 0
fi

echo "$(date) ses_to_go [$ses_to_go]" >> /tmp/session_kill.log


#  switch to random next session
tmux switch-client -n &

sleep 2

tmux kill-session -t "$ses_to_go"
 
