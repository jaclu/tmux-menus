#!/bin/sh

# Set up env for profiling
export TMUX_MENUS_PROFILING=1
export TMUX_MENUS_LOGGING_MINIMAL=2
export TMUX_MENUS_NO_DISPLAY=1

# Define plugin repo folder, needed for accessing other files
D_TM_BASE_PATH=$(cd -- "$(dirname -- "$0")/.." && pwd)

case "$1" in
# When this is run with the option reset, the cache is cleared and env is recreated
reset )
    # cleanout cache
    rm -rf "$D_TM_BASE_PATH"/cache  || exit 1
    # setup environment
    "$D_TM_BASE_PATH"/scripts/plugin_init.sh || exit 2
    echo "cache cleared and env initialized"
    ;;
"" ) ;;
*)
    echo "ERROR: valid params are: reset to clear cache and initialize env or nothing"
    exit 1
esac

# The first run after clearing the cache and env has been prepared will be much slower,
# since cache is being recreated and this is normal, but still a number worth remembering.
#
# Repeated runs will be much faster due to cache, so that they are fairly low and consistent
# is more significant
#
# To profile a menu, replace the line"
#
#   . "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
#
# with:
#
#   # temp  profiling code to check performance
#   [ "$profiling_sourced" != 1 ] && . "$D_TM_BASE_PATH"/scripts/utils/dbg_profiling.sh
#   . "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
#   profiling_display "after dialog_handling"


"$D_TM_BASE_PATH"/items/main.sh

