#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Main menu, the one popping up when you hit the trigger
#

# Global check exclude
# shellcheck disable=SC2034,SC2154


# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Main menu"
req_win_width=40
req_win_height=20


search_all="command-prompt -p \"Search for:\" \"find-window -CNTiZ -- '%%'\""
open_menu="run-shell '$CURRENT_DIR"

#
#  Nested quotes only gets you so far, there is only " ' and \"
#  I wish it would be, but \' is not yet valid.
#  Thus I can't use spaces in the below display statements
#
set --  "command-prompt -I '~/.tmux.conf' -p 'Source file:'"                \
        "'run-shell \"$TMUX_BIN source-file %% && $TMUX_BIN display "       \
        "Sourced_it! || $TMUX_BIN display "                                 \
        "File_could_not_be_sourced-not_found?  \"'"
source_it="$*"

t_start="$(date +'%s')"

# shellcheck disable=SC2154
$TMUX_BIN display-menu                                                          \
    -T "#[align=centre] $menu_name "                                            \
    -x "$menu_location_x" -y "$menu_location_y"                                 \
                                                                                \
    "Handling Pane      -->"            P  "$open_menu/panes.sh'"               \
    "Handling Window    -->"            W  "$open_menu/windows.sh'"             \
    "Handling Sessions  -->"            S  "$open_menu/sessions.sh'"            \
    "Layouts            -->"            L  "$open_menu/layouts.sh'"             \
    "Split view         -->"            V  "$open_menu/split_view.sh'"          \
    "Extras             -->"            E  "$open_menu/extras.sh'"              \
    "Advanced Options   -->"            A  "$open_menu/advanced.sh'"            \
    ""                                                                          \
    "Public IP"                         i  "run \"curl --silent http://ip.me\"" \
    "Plugins inventory"                 p  "run $SCRIPT_DIR/plugins.sh"         \
    ""                                                                          \
    "Navigate & select ses/win/pane"    n  "choose-tree -Z"                     \
    "-#[nodim]Search in all sessions & windows" "" ""                           \
    " ignores case, only visible part"  s  "$search_all"                        \
    ""                                                                          \
    "    Reload configuration file"     r  "$source_it"                         \
    "<P> Detach from tmux"              d  detach-client                        \
    ""                                                                          \
    "Help  -->"  H  "$open_menu/help.sh $CURRENT_DIR/main.sh'"

ensure_menu_fits_on_screen
