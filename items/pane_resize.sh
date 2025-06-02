#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Resize a pane
#

static_content() {

    set -- \
        0.0 M Left "Back to Handling Pane  $nav_prev" panes.sh \
        0.0 M Home "Back to Main menu      $nav_home" main.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        0.0 C u "up" "resize-pane -U $runshell_reload_mnu" \
        0.0 C d "down" "resize-pane -D $runshell_reload_mnu" \
        0.0 C l "left" "resize-pane -L $runshell_reload_mnu" \
        0.0 C r "right" "resize-pane -R $runshell_reload_mnu" \
        0.0 S \
        0.0 C U "up    by  5" "resize-pane -U 5 $runshell_reload_mnu" \
        0.0 C D "down  by  5" "resize-pane -D 5 $runshell_reload_mnu" \
        0.0 C L "left  by 10" "resize-pane -L 10 $runshell_reload_mnu" \
        0.0 C R "right by 10" "resize-pane -R 10 $runshell_reload_mnu" \
        0.0 S \
        1.8 C s "Specify width & height" "command-prompt -p \
            'Pane width,Pane height' 'resize-pane -x %1 -y %2'"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Resize Pane"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
