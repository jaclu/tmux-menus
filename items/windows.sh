#!/bin/sh
#
#   Copyright (c) 2022-2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling Window
#

static_content() {
    set -- \
        0.0 M Home "Back to Main      $nav_home" "$cfg_main_menu" \
        0.0 M S "Split             $nav_next" window_split.sh \
        0.0 M M "Move              $nav_next" window_move.sh \
        0.0 M L "Layouts           $nav_next" "$d_items/layouts.sh $0 $menu_name"
    menu_generate_part 1 "$@"
    display_commands_toggle 2

    # def bindings
    #  Previous window with an alert    <p> M-p
    #  Next window with an alert        <p> M-n
    set -- \
        0.0 S \
        1.5 C r "Rename" "command-prompt -I '#W'  \
            -p 'New name: ' 'rename-window %%' $runshell_reload_mnu" \
        1.3 C a "New after current" "command-prompt -p \
            'Name of new: ' 'new-window -a -n \"%%\"' $runshell_reload_mnu" \
        1.3 C e "New at the end" "command-prompt -p \
            'Name of new: ' 'new-window -n \"%%\"' $runshell_reload_mnu" \
        1.7 C s "Display size" "display-message \
            'Size: #{window_width}x#{window_height}' $runshell_reload_mnu" \
        0.0 S \
        0.0 C l "Last selected" "last-window $runshell_reload_mnu" \
        0.0 C p "Previous" "previous-window $runshell_reload_mnu" \
        0.0 C n "Next" "next-window $runshell_reload_mnu" \
        0.0 C M-p "Previous (alert)" "previous-window -a $runshell_reload_mnu" \
        0.0 C M-n "Next     (alert)" "next-window -a $runshell_reload_mnu" \
        2.7 C c "Choose" "choose-tree -Zw" \
        0.0 S \
        1.8 C x "${cfg_danger_zone}Kill current" "confirm-before -p \
            'kill-window #W? (y/n)' kill-window  $runshell_reload_mnu" \
        1.8 C o "${cfg_danger_zone}Kill all other" "confirm-before -p \
            'Are you sure you want to kill all other? (y/n)' \
            'run-shell \"${d_scripts}/kill_other_windows.sh\"' $runshell_reload_mnu"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Handling Windows"

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/.." && pwd)

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/menu_handling.sh
