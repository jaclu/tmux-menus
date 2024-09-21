#!/bin/sh
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Split display
#

static_content() {
    set -- \
        0.0 M Left "Back to Main menu <--" main.sh \
        0.0 S \
        0.0 T "-#[align=centre,nodim]----  Split Pane  ----" \
        2.0 C l "Left" "split-window     -hb -c '#{pane_current_path}' $menu_reload" \
        1.7 C r "Right" "split-window -h  -c '#{pane_current_path}' $menu_reload" \
        2.0 C a "Above" "split-window    -vb -c '#{pane_current_path}' $menu_reload" \
        1.7 C b "Below" "split-window -v  -c '#{pane_current_path}' $menu_reload" \
        0.0 T "-#[align=centre,nodim]---  Split Window  ---" \
        2.4 C L "Left" "split-window -fhb -c '#{pane_current_path}' $menu_reload" \
        2.4 C R "Right" "split-window -fh  -c '#{pane_current_path}' $menu_reload" \
        2.4 C A "Above" "split-window -fvb -c '#{pane_current_path}' $menu_reload" \
        2.4 C B "Below" "split-window -fv  -c '#{pane_current_path}' $menu_reload" \
        0.0 S \
        0.0 M H "Help -->" "$d_items/help_split.sh $f_current_script"

    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Split view"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

e="$?"
if [ "$e" -ne 0 ]; then
    log_it "$current_script exiting [$e]"
fi
