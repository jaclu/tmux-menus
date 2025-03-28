#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Sources config file, tries to guess current config file,
#   Gives prompt to correct if need-be
#

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/helpers.sh
. "$D_TM_BASE_PATH"/scripts/helpers.sh

log_it "running: $0 $1"

if tmux_error_handler source-file "$1"; then
    _m="Sourced it!"
    log_it "$_m"
    tmux_error_handler display "$_m"
else
    _m="tmux config file could not be sourced: $1"
    log_it "$_m"
    tmux_error_handler display "$_m"
fi
