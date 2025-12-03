#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Choose layout
#

dynamic_content() {
    t_opt="pane-border-indicators"
    _cmd="set-option -w $t_opt" # only change on a per window basis
    lbl_off="off"
    lbl_color="colour"
    lbl_arrows="arrows"
    lbl_both="both"
    win_option="$($TMUX_BIN show-options -wv "$t_opt")"

    if [ -n "$win_option" ]; then
        case "$win_option" in
            off) lbl_off="-off" ;;
            colour) lbl_color="-colour" ;;
            arrows) lbl_arrows="-arrows" ;;
            both) lbl_both="-both" ;;
            *) error_msg "Unknown $t_opt -w option: $win_option" ;;
        esac
    else
        glob_option="$($TMUX_BIN show-options -gv "$t_opt")"
        case "$glob_option" in
            off) lbl_off="-(glob) off" ;;
            colour) lbl_color="-(glob) colour" ;;
            arrows) lbl_arrows="-(glob) arrows" ;;
            both) lbl_both="-(glob) both" ;;
            *) error_msg "Unknown $t_opt -g option: $glob_option" ;;
        esac
    fi

    set -- \
        3.3 C "o" "$lbl_off"    "$_cmd  off     $runshell_reload_mnu" \
        3.3 C "c" "$lbl_color"  "$_cmd  colour  $runshell_reload_mnu" \
        3.3 C "a" "$lbl_arrows" "$_cmd  arrows  $runshell_reload_mnu" \
        3.3 C "b" "$lbl_both"   "$_cmd  both    $runshell_reload_mnu"
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

menu_name="Layouts - Border Indicators"
menu_min_vers=3.3

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd -- "$(dirname -- "$0")/.." && pwd)

. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
