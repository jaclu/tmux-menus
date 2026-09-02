#!/bin/sh
#
#   Copyright (c) 2022-2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Define how pane lines should be displayed
#

handle_pane_border_status() {
    t_opt="pane-border-status"
    _cmd="set-option -w $t_opt" # only change on a per window basis
    lbl_off="Off"
    lbl_top="Top"
    lbl_bottom="Bottom"
    lbb_top_float="top-floating"
    lbl_bot_float="bottom-floating"

    win_option=$($TMUX_BIN show-options -wv "$t_opt")
    glob_option=$($TMUX_BIN show-options -gv "$t_opt")
    [ -z "$win_option" ] && [ -z "$glob_option" ] && {
        # only fall-back to global if there is any
        win_option=single
    }
    case "$win_option" in
        off) lbl_off="-$lbl_off" ;;
        top) lbl_top="-$lbl_top" ;;
        bottom) lbl_bottom="-$lbl_bottom" ;;
        top-floating) lbb_top_float="-$lbb_top_float" ;;
        bottom-floating) lbl_bot_float="-$lbl_bot_float" ;;
        "") # No win option - use global as current
            case "$glob_option" in
                off) lbl_off="-(global) $lbl_off" ;;
                top) lbl_top="-(global) $lbl_top" ;;
                bottom) lbl_bottom="-(global) $lbl_bottom" ;;
                top-floating) lbb_top_float="-(global) $lbb_top_float" ;;
                bottom-floating) lbl_bot_float="-(global) $lbl_bot_float" ;;
                *) error_msg "Unknown global option: $t_opt [$glob_option]" ;;
            esac
            ;;
        *) error_msg "Unknown win option: $t_opt [$win_option]" ;;
    esac
    set -- \
        0.0 T "-" \
        0.0 T "-#[align=centre,nodim]pane-border-status" \
        2.3 C o "$lbl_off" "$_cmd  off              $runshell_reload_mnu" \
        2.3 C t "$lbl_top" "$_cmd  top              $runshell_reload_mnu" \
        2.3 C b "$lbl_bottom" "$_cmd  bottom           $runshell_reload_mnu" \
        3.7z C 1 "$lbb_top_float" "$_cmd  top-floating     $runshell_reload_mnu" \
        3.7z C 2 "$lbl_bot_float" "$_cmd  bottom-floating  $runshell_reload_mnu"
    menu_generate_part 4 "$@"
}

handle_pane_border_lines() {
    t_opt="pane-border-lines"
    _cmd="set-option -w $t_opt" # only change on a per window basis
    lbl_single="Single"
    lbl_double="Double"
    lbl_heavy="Heavy"
    lbl_simple="Simple"
    lbl_number="Number"
    lbl_spaces="Spaces"
    lbl_none="None"

    win_option="$($TMUX_BIN show-options -wv "$t_opt")"
    glob_option="$($TMUX_BIN show-options -gv "$t_opt")"
    [ -z "$win_option" ] && [ -z "$glob_option" ] && {
        # only fall-back to global if there is any
        win_option=single
    }
    case "$win_option" in
        single) lbl_single="-$lbl_single" ;;
        double) lbl_double="-$lbl_double" ;;
        heavy) lbl_heavy="-$lbl_heavy" ;;
        simple) lbl_simple="-$lbl_simple" ;;
        number) lbl_number="-$lbl_number" ;;
        spaces) lbl_spaces="-$lbl_spaces" ;;
        none) lbl_none="-$lbl_none" ;;
        "") # No win option - use global as current
            case "$glob_option" in
                single) lbl_single="-(global) $lbl_single" ;;
                double) lbl_double="-(global) $lbl_double" ;;
                heavy) lbl_heavy="-(global) $lbl_heavy" ;;
                simple) lbl_simple="-(global) $lbl_simple" ;;
                number) lbl_number="-(global) $lbl_number" ;;
                spaces) lbl_spaces="-(global) $lbl_spaces" ;;
                none) lbl_none="-(global) $lbl_none" ;;
                *) error_msg "Unknown global option: $t_opt [$glob_option]" ;;
            esac
            ;;
        *) error_msg "Unknown win option: $t_opt [$win_option]" ;;
    esac

    # TODO: option none below did not work as per man page as late as 26-09-02
    #       disable is still broken by release
    no_border="No border for floating panes"
    set -- \
        3.2 T "-" \
        3.2 T "-#[align=centre,nodim]pane-border-lines" \
        3.2 C s "$lbl_single" "$_cmd  single  $runshell_reload_mnu" \
        3.2 C d "$lbl_double" "$_cmd  double  $runshell_reload_mnu" \
        3.2 C h "$lbl_heavy" "$_cmd  heavy   $runshell_reload_mnu" \
        3.2 C i "$lbl_simple" "$_cmd  simple  $runshell_reload_mnu" \
        3.2 C \\# "$lbl_number" "$_cmd  number  $runshell_reload_mnu" \
        3.6 C p "$lbl_spaces" "$_cmd  spaces  $runshell_reload_mnu" \
        3.7z C n "$no_border" "$_cmd  none    $runshell_reload_mnu"
    menu_generate_part 5 "$@" #
}

dynamic_content() {
    tmux_vers_check 2.3 && handle_pane_border_status
    tmux_vers_check 3.2 && handle_pane_border_lines
}

static_content() {
    set -- \
        0.0 M Left "Back to Layouts    $nav_prev" layouts.sh \
        0.0 M Home "Back to Main menu  $nav_home" "$cfg_main_menu"
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2
    set -- \
        0.0 S \
        2.6 C c "Change Title" "command-prompt -I '#T' -p 'Pane title: ' \
            'select-pane -T \"%%\"' $runshell_reload_mnu"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Layouts - Border Lines"
menu_min_vers=2.3

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/.." && pwd)

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/menu_handling.sh
