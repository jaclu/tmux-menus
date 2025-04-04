#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Split display
#

static_content() {
    set -- \
        0.0 M Left "Back to Main menu  $nav_home" main.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        0.0 T "-#[align=centre,nodim]----  Split Pane  ----" \
        2.0 C l "Left" "split-window     -hb -c '#{pane_current_path}' $menu_reload" \
        1.7 C r "Right" "split-window -h  -c '#{pane_current_path}' $menu_reload" \
        2.0 C a "Above" "split-window    -vb -c '#{pane_current_path}' $menu_reload" \
        1.7 C b "Below" "split-window -v  -c '#{pane_current_path}' $menu_reload" \
        0.0 T "-#[align=centre,nodim]---  Split Window  ---" \
        2.4 C L "Left" "split-window -fhb -c '#{pane_current_path}' $menu_reload" \
        2.4 C R "Right" "split-window -fh  -c '#{pane_current_path}' $menu_reload" \
        2.4 C A "Above" "split-window -fvb -c '#{pane_current_path}' $menu_reload" \
        2.4 C B "Below" "split-window -fv  -c '#{pane_current_path}' $menu_reload" \
        0.0 S \
        0.0 M H "Help               $nav_next" "$d_help/help_split.sh $0"

    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Split view"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
