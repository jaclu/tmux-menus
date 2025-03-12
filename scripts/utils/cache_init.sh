#!/bin/sh
# Always sourced file - Fake bang path to help editors
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Try to init the cache if allowed

D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(dirname -- "$(realpath "$0")")")")"

initialize_plugin=1

# shellcheck source=/dev/null  # can't read source when mixing bah & posix
. "$D_TM_BASE_PATH"/scripts/helpers.sh

# shellcheck disable=SC2154
if [ "$initialize_plugin" = "1" ]; then
    # Create a LF in log_file to easier separate runs
    # log_it
    rm -f "$f_cached_tmux_options"
    get_config_refresh
fi


echo "D_TM_BASE_PATH [$D_TM_BASE_PATH]"
