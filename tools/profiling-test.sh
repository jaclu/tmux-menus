#!/usr/bin/env bash

# Define plugin repo folder, needed for accessing other files
D_TM_BASE_PATH=$(cd "${0%/*}/.." && pwd)

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh

# Set up env for profiling
export TMUX_MENUS_PROFILING=1
# export TMUX_MENUS_LOGGING_MINIMAL=1 # 1 - minimal 2 - no logging
export TMUX_MENUS_NO_DISPLAY=1

# If set to 1 all logging goes to stderr
# export log_interactive_to_stderr=1

case "$1" in
    # When this is run with the option reset, the cache is cleared and env is recreated
    # so this will typically have a longer processing time, run again to get
    # profiling for the cached state
    reset)
        # cleanout cache
        rm -rf "$D_TM_BASE_PATH"/cache || exit 1
        # setup environment
        "$D_TM_BASE_PATH"/scripts/plugin_init.sh || exit 2
        echo "cache cleared and env initialized"
        ;;
    "") ;;
    *)
        echo "ERROR: valid params are: reset to clear cache and initialize env or nothing"
        exit 1
        ;;
esac

# The first run after clearing the cache and env has been prepared will be much slower,
# since cache is being recreated and this is normal, but still a number worth remembering.
#
# Repeated runs will be much faster due to cache, so that they are fairly low and consistent
# is more significant
#
# To profile a menu, replace the line"
#
#   . "$D_TM_BASE_PATH"/scripts/menu_handling.sh
#
# with:
#
#   # temp  profiling code to check performance
#   [ "$profiling_sourced" != 1 ] && . "$D_TM_BASE_PATH"/scripts/utils/dbg_profiling.sh
#   . "$D_TM_BASE_PATH"/scripts/menu_handling.sh
#   profiling_display "after dialog_handling"

time "$D_TM_BASE_PATH"/items/main.sh
