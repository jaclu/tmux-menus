#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handle DropBox CLI tool
#

is_dropbox_running() {
    #
    #  Convert to boolean status from the dropox (python?) status logic
    #  where 1 means running and 0 means not running
    #
    dropbox running && return 1
    if [ "$(dropbox status)" = "Syncing..." ]; then
        #  status is only this whilst terminating, during normal operations
        #  it also mentions what file (-s) is being synced.
        #  So this is a sure sign dropbox is about to shut down,
        #  so can be labeled asnot running
        return 1
    else
        # is running
        return 0
    fi
}

dropbox_status_check() {
    is_dropbox_running && run_stat=0 || run_stat=1
    if [ "$run_stat" != "$1" ]; then
        return 0
    else
        return 1
    fi
}

prepare_env() {
    # shellcheck source=/dev/null
    . "$D_TM_BASE_PATH"/scripts/helpers.sh
}

#---------------------------------------------------------------
#
#   with cmdline options
#
#---------------------------------------------------------------

start_stop() {
    prepare_env

    if is_dropbox_running; then
        action="stop"
        new_run_stat=1
    else
        action="start"
        new_run_stat=0
    fi

    #
    #  Temp set a very high disp time, org value
    #  will be restored when script is done
    #
    # save value in a pre tmux 1.7 safe way, not relying on show-options -v
    org_disp_time="$($TMUX_BIN show-options -g display-time | cut -d' ' -f2)"
    tmux_error_handler set-option -g display-time 30000
    tmux_error_handler display-message "Doing dropbox $action ..."

    if [ "$action" = "start" ]; then
        #
        #  If dropbox was toggled on in the timeframe where it is still shutting
        #  down but has not completed that operation, wait for it to complete
        #  before triggering the start event.
        #
        while [ "$(dropbox status)" = "Syncing..." ]; do
            log_it " waiting for dropbox stop to complete..."
            sleep 1
        done
    fi

    log_it "dropbox_toggle.sh $action  ------"

    dropbox "$action" >/dev/null 2>&1 &
    log_it " action done, waiting for run stat: $new_run_stat"
    while dropbox_status_check "$new_run_stat"; do
        log_it " waiting for dropbox to change status into $new_run_stat..."
        sleep 1
    done

    log_it "status change completed"

    #
    # Hack to clear msg
    #
    tmux_error_handler set-option -g display-time 1
    tmux_error_handler display-message "" # clear status message
    # Restore org value
    [ -n "$org_disp_time" ] && {
        tmux_error_handler set-option -g display-time "$org_disp_time"
    }
    return 0
}

display_status() {
    prepare_env
    tmux_error_handler display "$(dropbox status)"
}

#---------------------------------------------------------------
#
#   menu definition
#
#---------------------------------------------------------------

static_content() {

    set -- \
        0.0 M Left "Back to Extras     $nav_prev" extras.sh \
        0.0 M Home "Back to Main menu  $nav_home" main.sh
    menu_generate_part 1 "$@"

    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        0.0 E s "Status" "$0 status ; $0 " \
        0.0 E t "toggle running status" "$0 toggle ; $0"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Dropbox"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(dirname -- "$(realpath "$0")")")")"

command -v dropbox >/dev/null || {
    prepare_env
    error_msg "Command not found: dropbox"
}

case "$1" in
toggle)
    start_stop
    exit 0
    ;;
status)
    display_status
    exit 0
    ;;
-h)
    echo "valid options: status / toggle (or none to run the menu)" >/dev/stderr
    exit 1
    ;;
*) ;;
esac

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
