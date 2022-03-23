#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.2.6 2022-03-15
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
#  By printing a NL and date, its easier to keep separate runs apart
#
log_it ""
log_it "$(date)"


trigger_key=$(get_tmux_option "@menus_trigger" "$default_key")
log_it "trigger_key=[$trigger_key]"


if bool_param "$(get_tmux_option "@menus_without_prefix" "0")"; then
    without_prefix=1
else
    without_prefix=0
fi
log_it "without_prefix=[$without_prefix]"


#
#  Generic plugin setting I use to add Notes to keys that are bound
#  This makes this key binding show up when doing <prefix> ?
#  If not set to "Yes", no attempt at adding notes will happen
#  bind-key Notes were added in tmux 3.1, so should not be used on older versions!
#
if bool_param "$(get_tmux_option "@plugin_use_notes" "No")"; then
    use_notes=1
else
    use_notes=0
fi
log_it "use_notes=[$use_notes]"


if [ "$without_prefix" -eq 1 ]; then
    if [ "$use_notes" -eq 1 ]; then
        tmux bind -N "tmux-menus" -n "$trigger_key" run-shell "$MENUS_DIR"/main.sh
    else
        tmux bind -n "$trigger_key" run-shell "$MENUS_DIR"/main.sh
    fi
    log_it "Menus bound to: $trigger_key"
else
    if [ "$use_notes" -eq 1 ]; then
        tmux bind -N "tmux-menus" "$trigger_key" run-shell "$MENUS_DIR"/main.sh
    else
        tmux bind    "$trigger_key" run-shell "$MENUS_DIR"/main.sh
    fi
    log_it "Menus bound to: <prefix> $trigger_key"
fi
