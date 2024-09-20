#!/bin/sh
#
#   Copyright (c) 2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling paste buffers
#

static_content() {
    set -- \
        0.0 M Left "Back to Main menu     <==" main.sh \
        0.0 C "[" "<P> Enter copy mode" "copy-mode" \
        0.0 C "]" "<P> Paste the most recent paste buffer" "paste-buffer -p" \
        1.8 C = "<P> Choose a paste buffer from a list" "choose-buffer -Z" \
        0.0 C "\#" "<P> List all paste buffers" "list-buffers" \
        0.0 C - "<P> Delete the most recent paste buffer" "delete-buffer" \
        0.0 M H "Help -->" "$d_items/help_paste_buffers.sh $f_current_script"

    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Paste buffers"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

e="$?"
if [ "$e" -ne 0 ]; then
    log_it "$current_script exiting [$e]"
fi
