#!/bin/sh
#
#   Copyright (c) 2022-2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling pane
#

static_content() {
    set -- \
        0.0 M Home "Back to Main      $nav_home" "$cfg_main_menu" \
        3.7 M F "Floating panes    $nav_next" floating_pane_combined.sh \
        0.0 M S "Split             $nav_next" pane_split.sh \
        0.0 M R "Resize            $nav_next" pane_resize.sh \
        0.0 M M "Move              $nav_next" pane_move.sh \
        0.0 M L "Layouts           $nav_next" "$d_items/layouts.sh $0 $menu_name" \
        0.0 M I "History           $nav_next" pane_history.sh

    if ! ${b_use_alt_handler:-false}; then
        set -- "$@" \
            1.1 M O "Logging           $nav_next" pane_log.sh
    fi

    menu_generate_part 1 "$@"
    display_commands_toggle 2

    respawn_action="confirm-before -p 'respawn-pane #P? (y/n)' \"respawn-pane -k\""
    respawn_action="$respawn_action $runshell_reload_mnu"
    set -- \
        0.0 S \
        2.6 C t "Rename (title)" "command-prompt -I '#T'  -p 'Title: '  \
            'select-pane -T \"%%\"' $runshell_reload_mnu" \
        1.8 C z "Toggle zoom" "resize-pane -Z $runshell_reload_mnu" \
        2.1 C m "Toggle mark" "select-pane -m $runshell_reload_mnu" \
        1.5 C s "Toggle synchronization" "set-option -w synchronize-panes $runshell_reload_mnu" \
        0.0 S \
        1.4 C l "Last selected" "last-pane $runshell_reload_mnu" \
        1.4 C p "Previous" "select-pane -t :.- $runshell_reload_mnu" \
        1.4 C n "Next" "select-pane -t :.+ $runshell_reload_mnu" \
        0.0 S \
        1.5 C r "${cfg_danger_zone}Respawn current" "$respawn_action" \
        1.8 C x "${cfg_danger_zone}Kill current" "confirm-before -p \
            'kill-pane #T (#P)? (y/n)' kill-pane $runshell_reload_mnu" \
        1.8 C o "${cfg_danger_zone}Kill all other" "confirm-before -p \
            'Are you sure you want to kill all other panes? (y/n)' \
            \"kill-pane -a\" $runshell_reload_mnu"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Handling Panes"

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/.." && pwd)

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/menu_handling.sh
