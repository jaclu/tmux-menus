#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.3.2 2022-05-08
#
#   Advanced options
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global


# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"


menu_name="Advanced options"
req_win_width=40
req_win_height=18

#
#  Gather some info in order to be able to show states
#
current_mouse_status="$(tmux show-option -g mouse | cut -d' ' -f2)"
if [ "$current_mouse_status" = "on" ]; then
    new_mouse_status="off"
else

    new_mouse_status="on"
fi
current_prefix="$(tmux show-option -g prefix | cut -d' ' -f2 | cut -d'-' -f2)"


this_menu="$CURRENT_DIR/advanced.sh"
reload="; run-shell '$this_menu'"
describe_prefix="command-prompt -k -p key 'list-keys -1N \"%%%\"'"
toggle_mouse="set-option -g mouse $new_mouse_status"
change_prefix="command-prompt -1 -p prefix 'run \"$SCRIPT_DIR/change_prefix.sh %%\"'"
kill_server="confirm-before -p 'kill tmux server on #H ? (y/n)' kill-server"


t_start="$(date +'%s')"

# shellcheck disable=SC2154,SC2140
tmux display-menu \
     -T "#[align=centre] $menu_name "             \
     -x "$menu_location_x" -y "$menu_location_y"  \
     \
     "Back to Main menu"     Left  "run-shell $CURRENT_DIR/main.sh"    \
     "Managet clients  -->"   M     "run-shell \"$CURRENT_DIR/advanced_manage_clients.sh\"" \
     "" \
     "<P> List all key bindings"          \?  "list-keys -N"           \
     "<P> Describe (prefix) key"           /  "$describe_prefix"       \
     "<P> Show messages"                  \~  show-messages            \
     "<P> Customize options"               C  "customize-mode -Z"      \
     "<P> Prompt for a command"            :  command-prompt           \
     "" \
     "Toggle mouse to: $new_mouse_status"  m  "$toggle_mouse $reload"  \
     "Change prefix <$current_prefix>"     p  "$change_prefix"         \
     "" \
     "-#[nodim]Kill server - all your sessions"       "" ""            \
     " on this host are terminated    "    k  "$kill_server"           \
     "" \
     "Help  -->"  H  "run-shell \"$CURRENT_DIR/help.sh $this_menu\""


ensure_menu_fits_on_screen
