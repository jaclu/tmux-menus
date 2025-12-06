#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Define how pane lines should be displayed
#

handle_pane_title() {
    t_opt="pane-border-status"
    _cmd="set-option -w $t_opt" # only change on a per window basis
    lbl_off="Off"
    lbl_top="Top"
    lbl_bottom="Bottom"
    win_option="$($TMUX_BIN show-options -wv "$t_opt")"

    if [ -n "$win_option" ]; then
        case "$win_option" in
            off) lbl_off="-Off" ;;
            top) lbl_top="-Top" ;;
            bottom) lbl_bottom="-Bottom" ;;
            *) error_msg "Unknown $t_opt -w option: $win_option" ;;
        esac
    else
        glob_option="$($TMUX_BIN show-options -gv "$t_opt")"
        case "$glob_option" in
            off) lbl_off="-(glob) Off" ;;
            top) lbl_top="-(glob) Top" ;;
            bottom) lbl_bottom="-(glob) Bottom" ;;
            *) error_msg "Unknown $t_opt -g option: $glob_option" ;;
        esac
    fi

    set -- \
        2.5 C o "$lbl_off" "$_cmd     off     $runshell_reload_mnu" \
        2.5 C t "$lbl_top" "$_cmd     top     $runshell_reload_mnu" \
        2.5 C b "$lbl_bottom" "$_cmd  bottom  $runshell_reload_mnu"
    menu_generate_part 4 "$@"
}

handle_pane_border_lines() {
    t_opt="pane-border-lines"
    _cmd="set-option -w $t_opt" # only change on a per window basis
    lbl_single="Single"
    lbl_double="Double"
    lbl_heavy="Heavy"
    lbl_simple="sImple"
    lbl_number="Number"
    lbl_spaces="Spaces"
    win_option="$($TMUX_BIN show-options -wv "$t_opt")"

    if [ -n "$win_option" ]; then
        case "$win_option" in
            single) lbl_single="-Single" ;;
            double) lbl_double="-Double" ;;
            heavy) lbl_heavy="-Heavy" ;;
            simple) lbl_simple="-sImple" ;;
            number) lbl_number="-Number" ;;
            spaces) lbl_spaces="-Spaces" ;;
            *) error_msg "Unknown $t_opt -w option: $win_option" ;;
        esac
    else
        glob_option="$($TMUX_BIN show-options -gv "$t_opt")"
        case "$glob_option" in
            single) lbl_single="-(glob) Single" ;;
            double) lbl_double="-(glob) Double" ;;
            heavy) lbl_heavy="-(glob) Heavy" ;;
            simple) lbl_simple="-(glob) sImple" ;;
            number) lbl_number="-(glob) Number" ;;
            spaces) lbl_spaces="-(glob) Spaces" ;;
            *) error_msg "Unknown $t_opt -g option: $glob_option" ;;
        esac
    fi

    set -- \
        3.2 C s "$lbl_single" "$_cmd  single  $runshell_reload_mnu" \
        3.2 C d "$lbl_double" "$_cmd  double  $runshell_reload_mnu" \
        3.2 C h "$lbl_heavy" "$_cmd   heavy   $runshell_reload_mnu" \
        3.2 C i "$lbl_simple" "$_cmd  simple  $runshell_reload_mnu" \
        3.2 C n "$lbl_number" "$_cmd  number  $runshell_reload_mnu" \
        3.6 C p "$lbl_spaces" "$_cmd  spaces  $runshell_reload_mnu"
    menu_generate_part 6 "$@"
}

dynamic_content() {
    handle_pane_title
    tmux_vers_check 3.2 && handle_pane_border_lines
}

static_content() {
    # shellcheck disable=SC2154 # cfg_main_menu is set in helpers_minimal.sh
    set -- \
        0.0 M Left "Back to Layouts    $nav_prev" layouts.sh \
        0.0 M Home "Back to Main menu  $nav_home" "$cfg_main_menu"
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2
    set -- \
        0.0 S \
        0.0 T "-#[align=centre,nodim]pane title"
    menu_generate_part 3 "$@"

    set -- \
        2.5 C c "Change" "command-prompt -I '#T' -p 'Pane title: ' \
            'select-pane -T \"%%\"' $runshell_reload_mnu" \
        3.2 T "-" \
        3.2 T "-#[align=centre,nodim]pane border lines"
    menu_generate_part 5 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Layouts - Border Lines"
menu_min_vers=2.5

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd -- "$(dirname -- "$0")/.." && pwd)

. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
