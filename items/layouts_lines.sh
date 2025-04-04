#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Choose layout
#

static_content() {
    set -- \
        0.0 M Left "Back to Layouts    $nav_prev" layouts.sh \
        0.0 M Home "Back to Main menu  $nav_home" main.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        3.2 S \
        3.2 T "-#[align=centre,nodim]pane-border-lines" \
        3.2 C "s" "single" "set -g pane-border-lines  single  $menu_reload" \
        3.2 C "d" "double" "set -g pane-border-lines  double  $menu_reload" \
        3.2 C "h" "heavy" "set -g pane-border-lines  heavy   $menu_reload" \
        3.2 C "S" "simple" "set -g pane-border-lines  simple  $menu_reload" \
        3.2 C "n" "number" "set -g pane-border-lines  number  $menu_reload"

    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Layouts - Lines"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
