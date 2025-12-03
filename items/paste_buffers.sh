#!/bin/sh
#
#   Copyright (c) 2025,2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling paste buffers
#

static_content() {

    select_cmd="$TMUX_BIN choose-buffer"
    tmux_vers_check 2.6 && select_cmd="$select_cmd -Z"

    if $cfg_use_hint_overlays && ! $cfg_use_whiptail; then
        select_cmd="$select_cmd \& $d_hints/choose-buffer.sh skip-oversized"
    fi

    # shellcheck disable=SC2154 # cfg_main_menu is set in helpers_minimal.sh
    set -- \
        0.0 M Left "Back to Main menu  $nav_home" "$cfg_main_menu"
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S

    if ! $cfg_use_whiptail; then
        set -- "$@" \
            0.0 C v "Paste the most recent paste buffer" "paste-buffer -p  $runshell_reload_mnu"
    fi
    set -- "$@" \
        1.8 E s "Select a paste buffer from a list" "$select_cmd" \
        0.0 C l "List all paste buffers" "list-buffers" \
        0.0 C d "Delete the most recent paste buffer" "delete-buffer ; list-buffers" \
        0.0 S

    $cfg_use_hint_overlays && $cfg_show_key_hints && {
        set -- "$@" \
            0.0 M S "Key hints - Select paste buffer $nav_next" \
            "$d_hints/choose-buffer.sh $0"
    }
    set -- "$@" \
        0.0 M H "Help               $nav_next" \
        "$d_help/help_paste_buffers.sh $0"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Paste buffers"

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd -- "$(dirname -- "$0")/.." && pwd)

. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
