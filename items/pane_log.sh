#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling pane logging
#

log_to_file() {
    _f_log="$1"

    if [ -n "$_f_log" ]; then
        $TMUX_BIN pipe-pane "cat >>$_f_log"
    else
        $TMUX_BIN display-message "No file name provided, logging disabled"
        $TMUX_BIN pipe-pane
    fi
}

static_content() {
    # shellcheck disable=SC2154 # cfg_main_menu is set in helpers_minimal.sh
    set -- \
        0.0 M Left "Back to Handling Pane  $nav_prev" panes.sh \
        0.0 M Home "Back to Main menu      $nav_home" "$cfg_main_menu"
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        1.1 C l "Log to file" "command-prompt -p 'Dest file:' \
            -I '$HOME/tmp/pane-output.log' \
            'run-shell \"$0 --log-file %1\"'"

    tmux_vers_check 2.6 || {
        # before 2.6 it can't be detected if pane is piped, so the Clear logging
        # is always displayed
        set -- "$@" \
            1.1 C c "Clear logging (if enabled)" "pipe-pane $runshell_reload_mnu"
    }
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Saving pane output to file"

# Be aware: If pane is piped can only be detected from 2.6, so before
menu_min_vers=1.1

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd -- "$(dirname -- "$0")/.." && pwd)

no_auto_menu_handling=1 # delay processing of dialog, only source it for now
. "$D_TM_BASE_PATH"/scripts/menu_handling.sh

if $cfg_use_whiptail; then
    # It "should" work, but something is going wrong and I haven't figured it out yet...
    error_msg "Menu pane_log is not yet usable for whiptail/dialog"
    exit 1
fi

case "$1" in
    --log-file) log_to_file "$2" ;;
    *) ;;
esac

tmux_vers_check 2.6 && {
    # #{pane_pipe} can be used to detect if pane is currently being logged

    dynamic_content() {

        if [ "$($TMUX_BIN display -p '#{pane_pipe}')" = 1 ]; then
            set -- \
                2.6 C c "Clear logging" "pipe-pane $runshell_reload_mnu"
        else
            # clear item if pane logging no longer is active
            set --
        fi
        menu_generate_part 4 "$@"
    }
}

# manually trigger dialog handling
do_menu_handling
