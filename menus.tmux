#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  shellcheck disable=SC2154


CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)

MENUS_DIR="$CURRENT_DIR/items"
SCRIPTS_DIR="$CURRENT_DIR/scripts"


#  shellcheck disable=SC1091
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
#  bind-key Notes were added in tmux 3.1, so should not be used on
#  older versions!
#
if bool_param "$(get_tmux_option "@use_bind_key_notes_in_plugins" "No")"; then
    use_notes=1
else
    use_notes=0
fi
log_it "use_notes=[$use_notes]"

params=""
if [ "$use_notes" -eq 1 ]; then
    #  shellcheck disable=SC2089
    params="$params -N plugin:$plugin_name"
fi
if [ "$without_prefix" -eq 1 ]; then
    params="$params -n"
    log_it "Menus bound to: $trigger_key"
else
    log_it "Menus bound to: <prefix> $trigger_key"
fi

if tmux_vers_compare 3.0 && [ "$FORCE_WHIPTAIL_MENUS" != "1" ]; then
    cmd="$MENUS_DIR/main.sh"
else
    if [ -z "$(command -v whiptail)" ]; then
        error_msg "whiptail is not installed!" 1
    fi
    cmd="$SCRIPTS_DIR/do_whiptail.sh"
fi

#  shellcheck disable=SC2086
$TMUX_BIN bind $params $trigger_key run-shell "$cmd"
