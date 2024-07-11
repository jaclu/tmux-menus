#!/bin/sh
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Resize a pane
#

static_content() {
    menu_name="Resize Pane"

    set -- \
        0.0 M Home "Back to Main menu     <==" main.sh \
        0.0 M Left "Back to Handling Pane <--" panes.sh \
        0.0 S \
        1.7 C s "Specify width & height" "command-prompt -p \
            'Pane width,Pane height' 'resize-pane -x %1 -y %2'" \
        0.0 T "-#[align=centre,nodim]-------  resize by 1  ------" \
        1.7 C u "up     " "resize-pane -U $menu_reload" \
        1.7 C d "down   " "resize-pane -D $menu_reload" \
        1.7 C l "left   " "resize-pane -L $menu_reload" \
        1.7 C r "right  " "resize-pane -R $menu_reload" \
        0.0 T "-#[align=centre,nodim]-------  resize by 5  ------" \
        1.7 C U "up" "resize-pane -U 5 $menu_reload" \
        1.7 C D "down" "resize-pane -D 5 $menu_reload" \
        1.7 C L "left" "resize-pane -L 5 $menu_reload" \
        1.7 C R "right" "resize-pane -R 5 $menu_reload" \
        0.0 S \
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
