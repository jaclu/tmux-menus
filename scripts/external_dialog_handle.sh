#!/bin/sh
#
#  Copyright (c) 2023-2025: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  This is run in the current pane, so job control is available
#

#  Full path to tmux-menus plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

. "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh
msg_prefix="external_dialog_handle.sh -"
menu_name="$1"
[ -z "$menu_name" ] && menu_name="$f_main_menu"
r_menu=$(relative_path "$menu_name")

log_it "><> $msg_prefix $0 $r_menu"

$menu_name

#
#  If a process was suspended, bring it back into fore-ground
#
pgrep -P "$PPID" | grep -qv "$$" && {
    log_it "$msg_prefix - will restore suspended app"
    . "$D_TM_BASE_PATH"/scripts/utils/define_tmux_bin.sh
    $TMUX_BIN send-keys fg Enter
}
log_it "><> $msg_prefix $0 $r_menu - done"
