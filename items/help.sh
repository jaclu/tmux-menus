#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   General Help
#

dynamic_content() {
    # Things that change dependent on various states

    menu_name="Help summary"

    if [ -z "$prev_menu" ]; then
        error_msg "help_split.sh was called without notice of what called it"
    fi

    set -- \
        0.0 M Left "Back to Previous menu <--" "$prev_menu"

    menu_generate_part 1 "$@"
}

static_content() {
    set -- \
        0.0 S \
        0.0 T "-#[nodim]'-->'  Indicates this will open a" \
        0.0 T "-#[nodim]'<--'  new menu." \
        0.0 S \
        0.0 T "-#[nodim]<P> Indicates this key is a default" \
        0.0 T "-#[nodim]    key, so unless it has been" \
        0.0 T "-#[nodim]    changed, it should be possible" \
        0.0 T "-#[nodim]    to use with <prefix> directly." \
        0.0 S \
        0.0 T "-#[nodim]Shortcut keys are usually upper case" \
        0.0 T "-#[nodim]for menus, and lower case for actions." \
        0.0 T "-#[nodim]Exit menus with ESC or Ctrl-C"

    menu_generate_part 2 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

prev_menu="$1"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath -- "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

e="$?"
if [ "$e" -ne 0 ]; then
    log_it "><> $current_script exiting [$e]"
fi
