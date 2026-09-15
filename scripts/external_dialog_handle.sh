#!/bin/sh
#
#  Copyright (c) 2023-2025: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  This is run in the current pane, so job control is available
#

# Prevents handle_env_variables to be run by this process
skip_env_check=1

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/helpers_minimal.sh

menu_name="${1:-$cfg_main_menu}"
$menu_name

if pgrep -P "$PPID" | grep -qv "$$"; then
    $TMUX_BIN send-keys fg Enter
fi
