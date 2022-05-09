#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.4.3 2022-05-08
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

menu_name="Main menu"
req_win_width=40
req_win_height=17


run_shell="run-shell $CURRENT_DIR"
search_all="command-prompt -p \"Search for:\" \"find-window -CNTiZ -- '%%'\""

#
#  Nested quotes only gets you so far, there is only " ' and \"
#  I wish it would be, but \' is not yet valid.
#  Thus I can't use spaces in the below display statements
#
source_it="command-prompt -I '~/.tmux.conf' -p 'Source file:' \
    'run-shell \"tmux source-file %% && tmux display Sourced_it! || \
    tmux display File_could_not_be_sourced-not_found?  \"'"


t_start="$(date +'%s')"


# shellcheck disable=SC2154
tmux display-menu \
     -T "#[align=centre] $menu_name "             \
     -x "$menu_location_x" -y "$menu_location_y"  \
     \
     "Handling Pane      -->"            P  "$run_shell/panes.sh"       \
     "Handling Window    -->"            W  "$run_shell/windows.sh"     \
     "Handling Sessions  -->"            S  "$run_shell/sessions.sh"    \
     "Layouts            -->"            L  "$run_shell/layouts.sh"     \
     "Split view         -->"            V  "$run_shell/split_view.sh"  \
     "Advanced Options   -->"            A  "$run_shell/advanced.sh"    \
     "" \
     "-#[nodim]Search in all sessions & windows" "" ""                  \
     " ignores case, only visible part"  s  "$search_all"               \
     "Navigate & select ses/win/pane"    n  "choose-tree -Z"            \
     "" \
     "    Reload configuration file"     r  "$source_it"                \
     "<P> Detach from tmux"              d  detach-client               \
     "" \
     "Configuration  -->" C "run-shell \"$CURRENT_DIR/config.sh\""      \
     "Help  -->"  H  "run-shell \"$CURRENT_DIR/help.sh $CURRENT_DIR/main.sh\""


ensure_menu_fits_on_screen
