#!/bin/sh
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Select and modify paste buffers
#

static_content() {
    menu_name="Paste buffers"

    set -- \
        0.0 M Left "Back to Main menu     <==" main.sh \
        0.0 T "-#[align=centre,nodim]-----------   Commands   -----------" \
        0.0 T "-#[nodim]This assumes at least one tmux buffer is assigned!" \
        0.0 T "-#[nodim] " \
        1.8 T "-#[nodim]Enter - Paste selected buffer" \
        2.6 T "-#[nodim]C-s   - Search by name or content" \
        2.6 T "-#[nodim]n     Repeat last search" \
        2.6 T "-#[nodim]t     Toggle if buffer is tagged" \
        2.6 T "-#[nodim]T     Tag no buffers" \
        2.6 T "-#[nodim]C-t   Tag all buffers" \
        2.8 T "-#[nodim]p     Paste selected buffer" \
        2.8 T "-#[nodim]P     Paste tagged buffers" \
        2.6 T "-#[nodim]d     Delete selected buffer" \
        2.6 T "-#[nodim]D     Delete tagged buffers" \
        3.2 T "-#[nodim]e     Open the buffer in an editor" \
        2.6 T "-#[nodim]f     Enter a format to filter items" \
        2.6 T "-#[nodim]O     Change sort field" \
        3.1 T "-#[nodim]r     Reverse sort order" \
        2.6 T "-#[nodim]v     Toggle preview" \
        1.8 T "-#[nodim]q     Exit mode" \
        0.0 S \
        1.8 C = "<P>" "choose-buffer" \
        0.0 M H "Help -->" "$d_items/help.sh $f_current_script"

    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

e="$?"
if [ "$e" -ne 0 ]; then
    log_it "$current_script exiting [$e]"
fi
