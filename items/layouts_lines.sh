#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Define how pane lines should be displayed
#

static_content() {
    set -- \
        0.0 M Left "Back to Layouts    $nav_prev" layouts.sh \
        0.0 M Home "Back to Main menu  $nav_home" main.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    _c="set-option -w pane-border-status"
    set -- \
        0.0 S \
        0.0 T "-#[align=centre,nodim]pane title" \
        2.5 C o "Off" "$_c  off     $runshell_reload_mnu" \
        2.5 C t "Top" "$_c      top     $runshell_reload_mnu" \
        2.5 C b "Bottom" "$_c   bottom  $runshell_reload_mnu" \
        2.5 C c "Change" "command-prompt -I '#T' -p 'Pane title: ' \
            'select-pane -T \"%%\"' $runshell_reload_mnu" \
        3.2 T "-" \
        3.2 T "-#[align=centre,nodim]pane-border-lines" \
        3.2 C s "Single" "set-option pane-border-lines  single  $runshell_reload_mnu" \
        3.2 C d "Double" "set-option pane-border-lines  double  $runshell_reload_mnu" \
        3.2 C h "Heavy" "set-option  pane-border-lines  heavy   $runshell_reload_mnu" \
        3.2 C i "sImple" "set-option pane-border-lines  simple  $runshell_reload_mnu" \
        3.2 C n "Number" "set-option pane-border-lines  number  $runshell_reload_mnu"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Layouts - Border Lines"
menu_min_vers=2.5

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
