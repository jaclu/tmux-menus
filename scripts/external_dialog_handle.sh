#!/bin/sh
#
#  Copyright (c) 2023-2025: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  This is run in the current pane, so job control is available
#

do_resume() {
    #
    #  If a process was suspended, bring it back into fore-ground
    #
    pgrep -P "$PPID" | grep -qv "$$" && {
        log_it "$rn_current_script - will restore suspended app"
        . "$D_TM_BASE_PATH"/scripts/utils/define_tmux_bin.sh
        $TMUX_BIN send-keys fg Enter
    }
    safe_remove "$f_is_suspended"
    # log_it "$rn_current_script - $f_is_suspended - removed"
}

#  Full path to tmux-menus plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

. "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh

menu_name="$1"
[ -z "$menu_name" ] && menu_name="$f_main_menu"

$menu_name

if [ -f "$f_is_suspended" ]; then
    if [ -f "$f_is_suspended" ]; then
        mnu_depth=$(echo "$(cat "$f_is_suspended") - 1" | bc)
        echo "$mnu_depth" >"$f_is_suspended"
        if [ "$mnu_depth" -lt 1 ]; then
            do_resume
        # else
        #     log_it "$rn_current_script - $f_is_suspended - decreased to: $mnu_depth"
        fi
    fi
fi
# log_it "><> $msg_prefix $0 $r_menu - done"
