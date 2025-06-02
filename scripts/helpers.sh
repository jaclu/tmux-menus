#!/bin/sh
# Always sourced file - Fake bang path to help editors
#
#   Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Source the entire helpers suite
#

#===============================================================
#
#   Main
#
#===============================================================

[ -z "$TMUX_BIN" ] && TMUX_BIN="tmux"

[ -z "$D_TM_BASE_PATH" ] && {
    # helpers not yet sourced, so error_msg_safe() not yet available
    msg="ERROR: $0 - D_TM_BASE_PATH must be set!"
    (
        echo
        echo "$msg"
        echo
    ) >/dev/stderr
    $TMUX_BIN display-message "$msg"
    exit 1
}

# shellcheck source=scripts/helpers_minimal.sh
. "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh

$all_helpers_sourced || source_all_helpers "helpers.sh"

# log_it "===  Completed: scripts/helpers_full.sh  == [$0]"
