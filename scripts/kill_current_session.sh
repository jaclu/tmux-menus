#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.2.1 2022-02-03
#
#   Kills current session. If this is the only session, it
#   first calls kill_session_confirm.sh where user can confirm
#   if this should still happen, since it will terminate the tmux server.
#

CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

force_directive="force"

ses_count="$(tmux list-sessions | wc -l)"

ses_to_go="$(tmux display-message -p '#{session_id}')"

if [ -z "$ses_to_go" ]; then
    tmux display-message "ERROR: tmux-menus:kill_current_session.sh  Failed to identify current session!"
    exit 0
fi


if [ "$1" != "$force_directive" ]; then
    if [ $ses_count -lt 2 ]; then
        $CURRENT_DIR/kill_session_confirm.sh
        #
        # This script will be called again with the force param
        # if continuation is desired, this instance should now quit.
        #
        exit 0
    fi
fi


#
#  Switch to next session, in order not to get disconnected when active session
#  is terminated.
#
tmux switch-client -n &


if [ $ses_count -gt 1 ]; then
    #
    #  On some slower systems, like iSH it might actually take a second to
    #  switch sessions. If the client is still connected to the session when
    #  it gets killed it gets disconnected. Nothing major, the other sessions
    #  are still running, but its an unnesesarry anoyannce to have to
    #  reconnect. Combined with that this is not blocking anything,
    #  running in its own thread, it doesnt hurt to wait a bit.
    #
    sleep 2
fi


tmux kill-session -t "$ses_to_go"
 
