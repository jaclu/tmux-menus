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

CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ITEMS_DIR="$(dirname "$CURRENT_DIR")"
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

action="$1"

log_it "dropbox_toggle.sh $action"

case "$action" in

    'start' | 'stop') ;;

    *)
	error_msg "  invalid action: [$action]"
	exit 1
	;;

esac
dropbox "$action" > /dev/null 2>&1
log_it "  action done"
exit 0
