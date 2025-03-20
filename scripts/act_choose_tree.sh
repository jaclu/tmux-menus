#!/bin/sh
#
#   Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Since there is a limitation of only two levels of quoting when
#   using scripts/dialog_handling.sh this intermittent script is used to avoid
#   this limit
#

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/helpers_all.sh
. "$D_TM_BASE_PATH"/scripts/helpers_all.sh

# print_stderr "><> print_stderr cfg_log_file [$cfg_log_file] log_interactive_to_stderr [$log_interactive_to_stderr]"
# log_it "><> hepp"
# exit 1

if $cfg_use_hint_overlays && ! $cfg_use_whiptail; then
    "$d_hints"/choose-tree.sh skip-oversized &
fi

if tmux_vers_check 2.7; then
    flags="-GwZ"
else
    flags=""
fi
if [ "$1" = "P" ]; then
    template="$d_scripts/relocate_pane.sh P $2"
elif [ "$1" = "W" ]; then
    template="$d_scripts/relocate_window.sh W $2"
else
    error_msg_safe "$f_current_script: param 1 must be P or W"
fi

$TMUX_BIN choose-tree "$flags" "run-shell \"$template %%\""
