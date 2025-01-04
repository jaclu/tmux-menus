#!/bin/sh
#
#   Copyright (c) 2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling paste buffers
#

static_content() {
    list_buffer_cmd="choose-buffer"
    tmux_vers_check 2.6 && list_buffer_cmd="$list_buffer_cmd -Z"

    set -- \
        0.0 M Left "Back to Main menu     $nav_home" main.sh \
        0.0 S \
        0.0 C c "Enter copy mode" "copy-mode" \
        0.0 C v "Paste the most recent paste buffer" "paste-buffer -p" \
        1.8 C s "Select a paste buffer from a list" "$list_buffer_cmd" \
        0.0 C l "List all paste buffers" "list-buffers" \
        0.0 C d "Delete the most recent paste buffer" "delete-buffer" \
        0.0 S \
        0.0 M H "Help                  $nav_next" "$d_items/help_paste_buffers.sh $f_current_script" \
        0.0 M S "Help - Select buffer  $nav_next" "$d_items/help_paste_buffers_select.sh $f_current_script"

    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Paste buffers"
menu_min_vers=1.8

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
