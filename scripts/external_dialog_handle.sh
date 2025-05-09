#!/bin/sh
#
#  Copyright (c) 2023-2025: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  This is run in the current pane, so job control is available
#
#  I have tried to supply params for what menu to start but so far not succeeded
#  in poviding params to this script, neither via cmd params or env variable
#  So for now it can only trigger the main menu
#

#  Full path to tmux-menus plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

f_std_alone_log="$D_TM_BASE_PATH"/scripts/utils/std_alone_log.sh
msg_prefix="external_dialog_handle.sh -"

$f_std_alone_log "$msg_prefix - will run main menu"

"$D_TM_BASE_PATH"/items/main.sh

#
#  If a process was suspended, bring it back into fore-ground
#
pgrep -P "$PPID" | grep -qv "$$" && {
    $f_std_alone_log "$msg_prefix - will restore suspended app"
    . "$D_TM_BASE_PATH"/scripts/utils/define_tmux_bin.sh
    $TMUX_BIN send-keys fg Enter
}
$f_std_alone_log "$msg_prefix done"
