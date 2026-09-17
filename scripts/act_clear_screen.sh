#!/bin/sh
#
#  Copyright (c) 2023-2026: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  Simulating a key-press sending one key
#
#  Especially when using tablets with keyboards, the number row might
#  be mapped to function keys, thus blocking several keys.
#  For some, me included. It is often quicker to use a menu to generate
#  missing keys, vs fiddling with cut and paste from some other source
#  for such keys.
#

#===============================================================
#
#   Main
#
#===============================================================

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/helpers.sh

#
#  The intent for $1 - next menu is to be provided using relative path
# to make the Display Commands listing more convenient, this isolates the path
# if it still was given as a full path
[ -n "$1" ] && {
    [ -x "$1" ] || {
        validate_relativise_path "$1" "$cfg_d_menus"
        error_msg "act_clear_Next menu is not executable: $relative_fname"
    }
}

if [ -n "$alt_menu_handler" ]; then
    clear
else
    tmux_error_handler send-keys C-l
fi

tmux_error_handler clear-history

[ -n "$1" ] && $1
