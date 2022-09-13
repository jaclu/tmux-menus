#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.0.1 2022-06-30
#
#   toggle dropbox on/off
#

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ITEMS_DIR="$(dirname "$CURRENT_DIR")"
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

dropbox_status_check() {
    is_dropbox_running && run_stat=0 || run_stat=1
    if [ "$run_stat" -ne "$1" ]; then
	return 0
    else
	return 1
    fi
}


if is_dropbox_running; then
    action="stop"
    new_run_stat=1
else
    action="start"
    new_run_stat=0
fi


#
#  Temp set a very high disp time, org value
#  will be restored when script is done
#
org_disp_time="$(tmux show -g display-time | cut -d' ' -f 2)"
tmux set-option -g display-time 30000

tmux display "Doing dropbox $action ..."

if [ "$action" = "start" ]; then
    #
    #  If dropbox was toggled on in the timeframe where it is still shutting
    #  down but has not completed that operation, wait for it to complete
    #  before triggering the start event.
    #
    while [ "$(dropbox status)" = "Syncing..." ]; do
	log_it " waiting for dropbox stop to complete..."
	sleep 1
    done

fi




log_it "dropbox_toggle.sh $action  --------------------"


dropbox "$action" > /dev/null 2>&1 &
log_it " action done, waiting for run stat: $new_run_stat"
while dropbox_status_check "$new_run_stat"; do
    log_it " waiting for dropbox to change status into $new_run_stat..."
    sleep 1
done

log_it "status change completed"

# Hack to clear msg
tmux set-option -g display-time 1
tmux display ""2

# Restore org value
tmux set-option -g display-time "$org_disp_time"

exit 0
