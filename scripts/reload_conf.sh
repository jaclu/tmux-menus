#!/bin/sh
# shellcheck disable=SC2034,SC2154
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Sources config file, tries to guess current config file,
#   Gives prompt to correct if need-be
#

write_config() {
    #
    #  When config_overrides is set this saves such settings
    #
    [ "$config_overrides" -ne 1 ] && return
    #log_it "write_config() x[$location_x] y[$location_y]"
    echo "location_x=$location_x" >"$custom_config_file"
    echo "location_y=$location_y" >>"$custom_config_file"
}

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname "$(cd -- "$(dirname -- "$0")" && pwd)")"

# shellcheck disable=SC1091
. "$D_TM_SCRIPTS"/scripts/utils.sh

_this="reload_conf.sh"
[ "$(basename "$0")" != "$_this" ] && error_msg "$_this should NOT be sourced"

conf_file="$(get_tmux_option "@menus_config_file" "$HOME/tmux.conf")"
conf="${TMUX_CONF:-$conf_file}"

$TMUX_BIN command-prompt -I "$conf" -p "Source file:" \
    "run-shell \"$TMUX_BIN source-file %% &&                        \
    $TMUX_BIN display 'Sourced it!' ||                              \
    $TMUX_BIN display 'File could not be sourced - not found?'"
