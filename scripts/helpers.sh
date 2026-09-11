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

[ "${env_initialized:-0}" -lt 1 ] && {
    # Only source if not done

    [ -z "$D_TM_BASE_PATH" ] && {
        # helpers not yet sourced, so error_msg() not yet available
        msg="ERROR: menu_handling.sh - D_TM_BASE_PATH must be set before sourcing this file"
        (
            echo
            echo "$msg"
            echo
        ) >/dev/stderr
        exit 1
    }
    # shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
    . "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh
}

${b_all_helpers_sourced:-false} || source_all_helpers "helpers.sh"

# log_it "===  Completed: scripts/helpers_full.sh  == [$0]"
