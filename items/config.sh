#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 0.0.1 2022-05-09
#
#   Main menu, the one popping up when you hit the trigger
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Configuration"
req_win_width=52
req_win_height=15


select_menu="run-shell $CURRENT_DIR"

this_menu="$CURRENT_DIR/config.sh"
reload="; $this_menu"

t_start="$(date +'%s')"

# shellcheck disable=SC2154
tmux display-menu \
     -T "#[align=centre] $menu_name "             \
     -x "$menu_location_x" -y "$menu_location_y"  \
     \
     "Back to Main menu"    Left  "$select_menu/main.sh"             \
     "Location of menus -->"  L   "$select_menu/config_location.sh"  \
     "" \
     "Clear cache" c "run-shell 'rm /tmp/menus.cache'"


ensure_menu_fits_on_screen
