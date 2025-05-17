#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Choose layout
#

static_content() {
    set -- \
        0.0 M Left "Back to Layouts    $nav_prev" layouts.sh \
        0.0 M Home "Back to Main menu  $nav_home" main.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        3.2 S \
        3.2 T "-#[align=centre,nodim]pane-border-lines" \
        3.2 C "s" "Single" "set-option pane-border-lines  single  $mnu_runshell_reload_b" \
        3.2 C "d" "Double" "set-option pane-border-lines  double  $mnu_runshell_reload_b" \
        3.2 C "h" "Heavy" "set-option  pane-border-lines  heavy   $mnu_runshell_reload_b" \
        3.2 C "i" "sImple" "set-option pane-border-lines  simple  $mnu_runshell_reload_b" \
        3.2 C "n" "Number" "set-option pane-border-lines  number  $mnu_runshell_reload_b"

    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Layouts - Border Lines"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
