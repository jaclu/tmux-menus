#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Updates global prefix, if prefix param is given
#

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/helpers.sh
. "$D_TM_BASE_PATH"/scripts/helpers.sh

rel_scr_name=$(relative_path "$0")
next_menu="$*"
log_it "><> $rel_scr_name next_menu: [$next_menu]"

tmux_error_handler_assign prefix_char command-prompt -1 -p \
    "Prefix key without C- (will take effect imeditally)" "display -p %%"
log_it "><> prefix: [$prefix_char]"

#
#  Since this is a critical param, make extra sure we have valid input
#
if [ -z "$prefix_char" ]; then
    error_msg "$rel_scr_name - No prefix given!"
elif [ "$(printf '%s' "$prefix_char" | wc -m)" -ne 1 ]; then
    error_msg "$rel_scr_name - Must be exactly one char! Was:[$prefix_char]"
fi

prefix="C-$(lowercase_it "$prefix_char")"

tmux_error_handler set-option -g prefix "$prefix"
tmux_error_handler display-message "Be aware <prefix> is now: $prefix"

# Only run if no errors up to now...
if [ -n "$next_menu" ]; then
    $next_menu
else
    log_it "$rel_scr_name - no next menu param given"
fi
