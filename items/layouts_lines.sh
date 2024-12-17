#!/bin/sh
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Choose layout
#

static_content() {
    set -- \
        0.0 M Home "Back to Main menu  $nav_home" main.sh \
        0.0 M Left "Back to Layouts    $nav_prev" layouts.sh \
        3.2 S \
        3.2 T "-#[align=centre,nodim]pane-border-lines" \
        3.2 C "s" "single" "set -g pane-border-lines  single  $menu_reload" \
        3.2 C "d" "double" "set -g pane-border-lines  double  $menu_reload" \
        3.2 C "h" "heavy" "set -g pane-border-lines  heavy   $menu_reload" \
        3.2 C "S" "simple" "set -g pane-border-lines  simple  $menu_reload" \
        3.2 C "n" "number" "set -g pane-border-lines  number  $menu_reload" \
        0.0 S \
        0.0 M H "Help $nav_next" "$d_items/help.sh $f_current_script"

    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Layouts - Lines"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
