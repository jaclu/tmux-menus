#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Display and appearance settings
#

dynamic_content() {
    t_detect="Auto (detect)"
    t_light="Light theme"
    t_dark="Dark theme"
    t_terminal="Terminal ANSI colours"
    t_current=$($TMUX_BIN show-options -v theme)
    case "$t_current" in
        detect)
            cur_theme="$t_detect"
            t_detect="-$t_detect"
            ;;
        light)
            cur_theme="$t_light"
            t_light="-$t_light"
            ;;
        dark)
            cur_theme="$t_dark"
            t_dark="-$t_dark"
            ;;
        terminal)
            cur_theme="$t_terminal"
            t_terminal="-$t_terminal"
            ;;
        *) cur_theme="Theme: $t_current" ;;
    esac
    rrm="$runshell_reload_mnu"
    set -- \
        0.0 S \
        0.0 T "#[align=centre,dim]Current: #[nodim]$cur_theme" \
        0.0 T "" \
        3.8 C a "$t_detect" "set-option theme detect $rrm" \
        3.8 C l "$t_light" "set-option theme light $rrm" \
        3.8 C d "$t_dark" "set-option theme dark $rrm" \
        3.8 C t "$t_terminal" "set-option theme terminal $rrm"
    menu_generate_part 3 "$@"
}

static_content() {
    set -- \
        0.0 M Home "Back to Main      $nav_home" "$cfg_main_menu" \
        3.8 M H "Help              $nav_next" "$d_help/h_display_settings.sh $0"
    menu_generate_part 1 "$@"
    display_commands_toggle 2
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Display Settings"
menu_min_vers=3.8

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh
