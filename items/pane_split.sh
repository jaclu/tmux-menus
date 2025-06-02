#!/bin/sh
#
#   Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Split display
#

static_content() {
    set -- \
        0.0 M Left "Back to Handling Pane  $nav_prev" panes.sh \
        0.0 M Home "Back to Main menu      $nav_home" main.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    if tmux_vers_check 1.7; then
        same_folder="-c '#{pane_current_path}'"
    else
        same_folder=""
    fi

    set -- \
        0.0 S \
        2.0 C l "Left" "split-window  -bh  $same_folder  $runshell_reload_mnu" \
        0.0 C r "Right" "split-window -h   $same_folder  $runshell_reload_mnu" \
        2.0 C a "Above" "split-window -bv  $same_folder  $runshell_reload_mnu" \
        0.0 C b "Below" "split-window      $same_folder  $runshell_reload_mnu"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Split pane"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
