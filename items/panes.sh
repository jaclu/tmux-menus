#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling pane
#

static_content() {
    set -- \
        0.0 M Left "Back to Main menu  $nav_home" main.sh \
        0.0 M M "Move pane          $nav_next" pane_move.sh \
        0.0 M R "Resize pane        $nav_next" pane_resize.sh \
        0.0 M S "Split pane         $nav_next" pane_split.sh \
        0.0 M I "Pane history       $nav_next" pane_history.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        1.8 C z "Toggle pane zoom" "resize-pane -Z $menu_reload" \
        2.1 C m "Toggle mark current pane" "select-pane -m $menu_reload" \
        1.9 C s "Toggle synchronized panes" "set -w synchronize-panes $menu_reload" \
        2.6 C t "Set Pane Title" "command-prompt -I '#T'  -p 'Title: '  \
            'select-pane -T \"%%\"' $menu_reload" \
        1.7 C '\#' "Display pane numbers" "display-panes $menu_reload" \
        1.7 C d "Display pane size" "display-message \
            'Pane: #P size: #{pane_width}x#{pane_height}' $menu_reload" \
        0.0 S \
        1.7 C l "Last selected pane" "last-pane $menu_reload" \
        1.7 C p "Previous pane [in order]" "select-pane -t - $menu_reload" \
        1.7 C n "Next     pane [in order]" "select-pane -t + $menu_reload" \
        0.0 S \
        2.0 C r "Respawn current pane" "confirm-before -p \
            'respawn-pane #P? (y/n)' 'respawn-pane -k' $menu_reload" \
        2.0 C x "Kill current pane" "confirm-before -p \
            'kill-pane #T (#P)? (y/n)' kill-pane  $menu_reload" \
        2.0 C o "Kill all other panes" "confirm-before -p \
            'Are you sure you want to kill all other panes? (y/n)' \
            'kill-pane -a'  $menu_reload"

    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Handling Pane"
# window_width=38
# window_height=23

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
