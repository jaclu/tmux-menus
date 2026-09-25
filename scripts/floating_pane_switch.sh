#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Switch to other floating pane on window (if any)
#

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/helpers_minimal.sh

tmux_vers_check 3.7 || {
    error_msg "switch_floating_pane() requires tmux 3.7"
}

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$d_scripts"/floating_pane_helpers.sh

switch_floating_pane "$1"
