#!/bin/sh
#
#   Copyright (c) 2025-2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling paste buffers
#

static_content() {

    select_cmd="$TMUX_BIN choose-buffer"
    tmux_vers_check 2.6 && select_cmd="$select_cmd -Z"

    if ${cfg_use_hint_overlays:-false} && ! ${b_use_alt_handler:-false}; then
        select_cmd="$select_cmd \& $d_hints/choose-buffer.sh skip-oversized"
    fi

    set -- \
        0.0 M Home "Back to Main     $nav_home" "$cfg_main_menu"

    ${cfg_use_hint_overlays:-false} && ${cfg_show_key_hints:-false} && {
        set -- "$@" \
            0.0 M S "Key hints - Select $nav_next" \
            "$d_hints/choose-buffer.sh $0"
    }

    set -- "$@" \
        0.0 M H "Help             $nav_next" \
        "$d_help/h_paste_buffers.sh $0"
    menu_generate_part 1 "$@"
    display_commands_toggle 2

    set -- \
        0.0 S

    if ! ${b_use_alt_handler:-false}; then
        set -- "$@" \
            0.0 C v "Paste latest" "paste-buffer -p  $runshell_reload_mnu"
    fi
    set -- "$@" \
        1.8 E s "Select from list" "$select_cmd" \
        0.0 C l "Show all" "list-buffers" \
        0.0 C d "${cfg_danger_zone}Delete latest" "delete-buffer ; list-buffers"

    ${cfg_use_hint_overlays:-false} && ${cfg_show_key_hints:-false} && {
        set -- "$@" \
            0.0 S \
            0.0 M S "Key hints - Select $nav_next" \
            "$d_hints/choose-buffer.sh $0"
    }
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Paste buffers"

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/.." && pwd)

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/menu_handling.sh
