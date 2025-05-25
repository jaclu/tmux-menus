#!/bin/sh
#
#  Copyright (c) 2023-2025: Jacob.Lundqvist@gmail.com
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

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/helpers_minimal.sh
. "$D_TM_BASE_PATH"/scripts/helpers.sh

#
#  The intent for $1 - next menu is to be provided using relative path
# to make the Display Commands listing more convenient, this isolates the path
# if it still was given as a full path
rel_path_menu="$(relative_path "$1")"
next_menu="$D_TM_BASE_PATH/$rel_path_menu"

if $cfg_use_whiptail; then
    clear
else
    tmux_error_handler send-keys C-l
fi

tmux_error_handler clear-history

[ -n "$1" ] && {
    log_it "><> $0 - will run: $next_menu"
    $next_menu
}
log_it "><> $0 - done"
