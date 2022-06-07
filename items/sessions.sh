#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.3.5 2022-06-08
#
#   Handling Sessions
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Handling Sessions"
req_win_width=39
req_win_height=15


this_menu="$CURRENT_DIR/sessions.sh"
reload="; run-shell \"$this_menu\""
open_menu="run-shell '$CURRENT_DIR"

rename="command-prompt -I '#S' 'rename-session -- \"%%\"'"
new_ses="command-prompt -p 'Name of new session: ' 'new-session -s \"%%\"'"

set --  "confirm-before -p"                                     \
        "'Are you sure you want to kill this session? (y/n)'"   \
        "'run \"${SCRIPT_DIR}/kill_current_session.sh\"'"
kill_current="$*"

set --  "confirm-before -p"                                          \
        "'Are you sure you want to kill all other sessions? (y/n)'"  \
        "'kill-session -a'"
kill_other="$*"


t_start="$(date +'%s')"

# shellcheck disable=SC2154
tmux display-menu                                                       \
    -T "#[align=centre] $menu_name "                                    \
    -x "$menu_location_x" -y "$menu_location_y"                         \
                                                                        \
    "Back to Main menu"  Left  "$open_menu/main.sh'"                    \
    ""                                                                  \
    "<P> Rename this session"          \$  "$rename"                    \
    "    New session"                   n  "$new_ses"                   \
    ""                                                                  \
    "<P> Last selected session"         L  "switch-client -l $reload"   \
    "<P> Previous session (in order)"  \(  "switch-client -p $reload"   \
    "<P> Next     session (in order)"  \)  "switch-client -n $reload"   \
    ""                                                                  \
    "Kill current session"              k  "$kill_current"              \
    "Kill all other sessions"           o  "$kill_other"                \
    ""                                                                  \
    "Help  -->"  H  "$open_menu/help.sh $this_menu'"

ensure_menu_fits_on_screen
