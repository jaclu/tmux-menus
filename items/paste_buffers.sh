#!/bin/sh
#
#   Copyright (c) 2024,2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling paste buffers
#

static_content() {
    choose_buffer="choose-buffer"
    tmux_vers_check 2.6 && choose_buffer="$choose_buffer -Z"

    if $cfg_use_whiptail; then
        # The help overlay can't be displayed using whiptail
        select_cmd="$TMUX_BIN $choose_buffer"
    else
        select_cmd="$TMUX_BIN $choose_buffer & $d_hints/choose-buffer.sh"
    fi

    set -- \
        0.0 M Left "Back to Main menu     $nav_home" main.sh \
        0.0 S \
        0.0 C c "Enter copy mode" "copy-mode" \
        0.0 C v "Paste the most recent paste buffer" "paste-buffer -p" \
        1.8 E s "Select a paste buffer from a list" "$select_cmd" \
        0.0 C l "List all paste buffers" "list-buffers" \
        0.0 C d "Delete the most recent paste buffer" "delete-buffer" \
        0.0 S \
        0.0 M S "Key hints - Select paste buffer  $nav_next" \
        "$d_hints/choose-buffer.sh $f_current_script" \
        0.0 M H "Help                             $nav_next" \
        "$d_help/help_paste_buffers.sh $f_current_script"

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
