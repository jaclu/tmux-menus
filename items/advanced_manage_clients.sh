#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.1.2 2022-05-08
#
#   Modify Clients
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global


# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Client Management"
req_win_width=41
req_win_height=28


t_start="$(date +'%s')"

# shellcheck disable=SC2154
tmux display-menu  \
     -T "#[align=centre] $menu_name "             \
     -x "$menu_location_x" -y "$menu_location_y"  \
     \
     "Back to Main menu"        Home  "run-shell $CURRENT_DIR/main.sh"      \
     "Back to Advanced options" Left  "run-shell $CURRENT_DIR/advanced.sh"  \
     "-#[align=centre,nodim]-----------   Commands   -----------"    "" ""  \
     "-Enter Choose selected client"                                 "" ""  \
     "-Up    Select previous client"                                 "" ""  \
     "-Down  Select next client"                                     "" ""  \
     "-C-s   Search by name"                                         "" ""  \
     "-n     Repeat last search"                                     "" ""  \
     "-t     Toggle if client is tagged"                             "" ""  \
     "-T     Tag no clients".                                        "" ""  \
     "-C-t   Tag all clients"                                        "" ""  \
     "-d     Detach selected client"                                 "" ""  \
     "-D     Detach tagged clients"                                  "" ""  \
     "-x     Detach and HUP selected client"                         "" ""  \
     "-X     Detach and HUP tagged clients"                          "" ""  \
     "-z     Suspend selected client"                                "" ""  \
     "-Z     Suspend tagged clients"                                 "" ""  \
     "-f     Enter a format to filter items"                         "" ""  \
     "-O     Change sort field"                                      "" ""  \
     "-r     Reverse sort order"                                     "" ""  \
     "-v     Toggle preview"                                         "" ""  \
     "-q     Exit mode"                                              "" ""  \
     "-" "" "" \
     "<P>"  D  "choose-client -Z"                                           \
     "" \
     "Help  -->"  H  "run-shell \"$CURRENT_DIR/help.sh $CURRENT_DIR/advanced_manage_clients.sh\""


ensure_menu_fits_on_screen
