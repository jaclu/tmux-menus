#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.2.1 2022-02-03
#


CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

MENUS_DIR="$CURRENT_DIR/items"
SCRIPTS_DIR="$CURRENT_DIR/scripts"

. "$SCRIPTS_DIR/utils.sh"


#
#  In shell script unlike in tmux, backslash needs to be doubled inside quotes.
#
default_key="\\"


#
#  If log_file is empty or undefined, no logging will occur, so normally
#  comment it out for normal usage.
#
#log_file="/tmp/tmux-menus.log"



#
#  Make it easy to see when a log run occured, also makes it easier
#  to separate runs of this script
#
log_it ""  # Trigger LF to separate runs of this script
log_it "$(date)"


trigger_key=$(get_tmux_option "@menus_trigger" "$default_key")
log_it "trigger_key=[$trigger_key]"

without_prefix=$(get_tmux_option "@menus_without_prefix" "0")
log_it "without_prefix=[$without_prefix]"


case "$without_prefix" in
    
    "0" | "1" ) ;;  # expected values

    "yes" | "Yes" | "YES" | "true" | "True" | "TRUE" )
	#  Be a nice guy and accept some common positives
        log_it "Converted incorret positive to 1"
        without_prefix=1
        ;;
    
    *)
        log_it "Invalid without_prefix value"
        tmux display 'ERROR: "@menus_without_prefix" should be 0 or 1'
        exit 0  # Exit 0 wont throw a tmux error

esac


if [ "$without_prefix" -eq 1 ]; then
    tmux bind -n "$trigger_key" run-shell "$MENUS_DIR"/main.sh
    log_it "Menus bound to: $trigger_key"
else
    tmux bind    "$trigger_key" run-shell "$MENUS_DIR"/main.sh
    log_it "Menus bound to: <prefix> $trigger_key"
fi
