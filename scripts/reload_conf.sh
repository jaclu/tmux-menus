#!/bin/sh
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Sources config file, tries to guess current config file,
#   Gives prompt to correct if need-be
#

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/helpers.sh
. "$D_TM_BASE_PATH"/scripts/helpers.sh

if tmux_error_handler source-file "$1"; then
    tmux_error_handler display 'Sourced it!'
else
    tmux_error_handler display 'File could not be sourced - not found?'
fi
