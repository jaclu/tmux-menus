#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Sources config file, tries to guess current config file,
#   Gives prompt to correct if need-be
#

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath -- "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/utils.sh
. "$D_TM_BASE_PATH"/scripts/utils.sh

$TMUX_BIN command-prompt -I "$cfg_tmux_conf" -p "Source file:" \
    "run-shell \"$TMUX_BIN source-file %% &&                   \
    $TMUX_BIN display 'Sourced it!' ||                         \
    $TMUX_BIN display 'File could not be sourced - not found?'"
