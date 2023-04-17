#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Advanced options
#

# Global check exclude
# shellcheck disable=SC2034,SC2154

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/dialog_handling.sh"

#
#  Gather some info in order to be able to show states
#
current_mouse_status="$($TMUX_BIN show-option -g mouse | cut -d' ' -f2)"
if [ "$current_mouse_status" = "on" ]; then
    new_mouse_status="off"
else
    new_mouse_status="on"
fi
current_prefix="$($TMUX_BIN show-option -g prefix | cut -d'-' -f2)"
plugin_conf_prompt="#{?@menus_config_overrides,Plugin configuration  -->,-Configuration disabled}"

describe_prefix="command-prompt -k -p key 'list-keys -1N \"%%%\"'"
change_prefix="command-prompt -1 -p 'prefix (will take effect imeditally)' 'run-shell \"$SCRIPT_DIR/change_prefix.sh %%\"'"
toggle_mouse="set-option -g mouse $new_mouse_status"
kill_server="confirm-before -p 'kill tmux server on #H ? (y/n)' kill-server"

menu_name="Advanced options"

set -- \
    0.0 M Left "Back to Main menu  <--" main.sh \
    0.0 M M "Manage clients     -->" advanced_manage_clients.sh \
    0.0 S \
    0.0 C ? "<P> List all key bindings" "list-keys -N" \
    0.0 C / "<P> Describe (prefix) key" "$describe_prefix" \
    0.0 C "\~" "<P> Show messages" show-messages \
    0.0 C C "<P> Customize options" "customize-mode -Z" \
    0.0 C : "<P> Prompt for a command" command-prompt \
    0.0 S \
    0.0 C m "Toggle mouse to: $new_mouse_status" "$toggle_mouse $menu_reload" \
    0.0 C p "Change prefix <$current_prefix>" "$change_prefix" \
    0.0 S \
    0.0 T "-#[nodim]Kill server - all your sessions" \
    0.0 C x " on this host are terminated    " "$kill_server" \
    0.0 S \
    0.0 M H "Help  -->" "$CURRENT_DIR/help.sh $current_script"

#
#  Disabled until I have time to investigate
#
# 0.0 M P "$plugin_conf_prompt" config.sh \

req_win_width=40
req_win_height=19

parse_menu "$@"
