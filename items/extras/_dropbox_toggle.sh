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

action="$1"

#
#  Convert to boolean status, from dropox (python) status logic
#
is_dropbox_running() {
    dropbox running && return 1
    if [ "$(dropbox status)" = "Syncing..." ]; then
	return 1  # it is terminating, so label it not running
    else
	# is running
	return 0
    fi
}


dropbox_status_check() {
    dropbox running && run_stat=1 || run_stat=0
    if [ "$run_stat" -ne "$1" ]; then
	return 0  # True
    else
	return 1  # False
    fi
}



#
#  Temp set a very high disp time, org value
#  will be restored when script is done
#
org_disp_time="$(tmux show -g display-time | cut -d' ' -f 2)"
tmux set-option -g display-time 30000

tmux display "Toggling dropbox status..."


if is_dropbox_running; then
    action="stop"
    new_run_stat=1
else
    action="start"
    new_run_stat=0
fi

log_it "dropbox_toggle.sh $action"


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
