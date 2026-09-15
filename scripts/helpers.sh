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

    # Prevents handle_env_variables to be run by this process
    skip_env_check=1

    # shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
    . "$TMUX_MENUS_LOCATION"/scripts/helpers_minimal.sh
}

${b_all_helpers_sourced:-false} || source_all_helpers "helpers.sh"

# log_it "===  Completed: scripts/helpers_full.sh  == [$0]"
