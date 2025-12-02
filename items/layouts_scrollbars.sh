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
    _c="set-option -w pane-scrollbars" # only change on a per window basis
    lbl_off="Off"
    lbl_modal="Modal (only in scrollback)"
    lbl_on="On"
    win_option="$($TMUX_BIN show-options -wv pane-scrollbars)"
    if [ -n "$win_option" ]; then
        case "$win_option" in
            off) lbl_off="-Off" ;;
            modal) lbl_modal="-Modal (only in scrollback)" ;;
            on) lbl_on="-On" ;;
            *) error_msg "Unknown -w pane-scrollbars option: $win_option" ;;
        esac
    else
        glob_option="$($TMUX_BIN show-options -gv pane-scrollbars)"
        case "$glob_option" in
            off) lbl_off="-(glob) Off" ;;
            modal) lbl_modal="-(glob) Modal (only in scrollback)" ;;
            on) lbl_on="-(glob) On" ;;
            *) error_msg "Unknown -g pane-scrollbars option: $glob_option" ;;
        esac
    fi

    set -- \
        0.0 S \
        3.6 C 0 "$lbl_off" "$_c  off  $runshell_reload_mnu" \
        3.6 C m "$lbl_modal" "$_c  modal  $runshell_reload_mnu" \
        3.6 C 1 "$lbl_on" "$_c   on   $runshell_reload_mnu"
    menu_generate_part 3 "$@"
}

static_content() {
    set -- \
        0.0 M Left "Back to Layouts    $nav_prev" layouts.sh \
        0.0 M Home "Back to Main menu  $nav_home" main.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2
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
