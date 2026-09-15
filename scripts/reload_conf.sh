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

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/helpers.sh

log_it "running: $0 $1"

if tmux_error_handler source-file "$1"; then
    _m="Sourced it successfully: $1"
    log_it "$_m"
    tmux_error_handler display-message "$_m"
else
    _m="tmux config file could not be sourced: $1"
    log_it "$_m"
    tmux_error_handler display-message "$_m"
fi
