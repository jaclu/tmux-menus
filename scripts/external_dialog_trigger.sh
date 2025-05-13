#!/bin/sh
#
#  Copyright (c) 2023-2025: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  This is run from tmux. In order to have access to job control, a second script
#  is simulated to be run in the active pane by using send-keys
#

do_suspend() {
    # suspend potential fg app
    $TMUX_BIN send-keys C-z || {
        error_msg_safe "Send C-z - exited with error: $?"
    }
    [ -d "$d_cache" ] && echo 1 >"$f_is_suspended"
}

#  Full path to tmux-menus plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

. "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh

menu_name="$1"
[ -z "$menu_name" ] && menu_name="$f_main_menu"

dlg_handler="$d_scripts/external_dialog_handle.sh"
[ ! -f "$dlg_handler" ] && error_msg_safe "File not found: $dlg_handler"

# r_triggger=$(relative_path "$f_ext_dlg_trigger")
# log_it "><> $r_triggger faking user-input: $rn_current_script"

if [ -f "$f_is_suspended" ]; then
    mnu_depth=$(echo "$(cat "$f_is_suspended") + 1" | bc)
    echo "$mnu_depth" >"$f_is_suspended"
    # log_it "$rn_current_script $f_is_suspended - increased count: $mnu_depth"
else
    do_suspend
    # log_it "$rn_current_script $f_is_suspended - created"
fi

sleep 0.2 # give time for task to be suspended, and shell ready for input

# start menu in active pane
eval "$TMUX_BIN" send-keys "$dlg_handler" Space "$menu_name" Enter || {
    error_msg_safe "$dlg_handler - exited with error: $?"
}
