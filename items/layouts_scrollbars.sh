#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Define how pane lines should be displayed
#

dynamic_content() {
    t_opt="pane-scrollbars"
    _cmd="set-option -w $t_opt" # only change on a per window basis
    lbl_off="Off"
    lbl_modal="Modal (only in scrollback)"
    lbl_on="On"
    win_option="$($TMUX_BIN show-options -wv "$t_opt")"

    if [ -n "$win_option" ]; then
        case "$win_option" in
            off) lbl_off="-Off" ;;
            modal) lbl_modal="-Modal (only in scrollback)" ;;
            on) lbl_on="-On" ;;
            *) error_msg "Unknown $t_opt -w option: $win_option" ;;
        esac
    else
        glob_option="$($TMUX_BIN show-options -gv "$t_opt")"
        case "$glob_option" in
            off) lbl_off="-(glob) Off" ;;
            modal) lbl_modal="-(glob) Modal (only in scrollback)" ;;
            on) lbl_on="-(glob) On" ;;
            *) error_msg "Unknown $t_opt -g option: $glob_option" ;;
        esac
    fi

    set -- \
        3.6 C o "$lbl_off"   "$_cmd  off    $runshell_reload_mnu" \
        3.6 C m "$lbl_modal" "$_cmd  modal  $runshell_reload_mnu" \
        3.6 C n "$lbl_on"    "$_cmd  on     $runshell_reload_mnu"
    menu_generate_part 4 "$@"
}

static_content() {
    # shellcheck disable=SC2154 # cfg_main_menu is set in helpers_minimal.sh
    set -- \
        0.0 M Left "Back to Layouts    $nav_prev" layouts.sh \
        0.0 M Home "Back to Main menu  $nav_home" "$cfg_main_menu"
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2
    set -- \
        0.0 S
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Layouts - Scrollbars"
menu_min_vers=3.6

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd -- "$(dirname -- "$0")/.." && pwd)

. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
