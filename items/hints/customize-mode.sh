#!/bin/sh
#
#   Copyright (c) 2022-2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help about splitting the view
#

dynamic_content() {
    # Things that change dependent on various states

    if [ -n "$prev_menu" ]; then
        set -- \
            0.0 M Left "Back to Previous  $nav_prev" "$prev_menu" \
            0.0 M Home "Back to Main      $nav_home" "$cfg_main_menu"
    else
        set -- \
            0.0 T "Press Esc or q to close this help overlay"
    fi
    menu_generate_part 1 "$@"
}

static_content() {
    if tmux_vers_check "3.5"; then
        # Description was changed
        forwards_hint="forwards"
    fi
    set -- \
        3.2 S \
        3.2 T "Enter  Set option value" \
        3.2 T "Up     Select previous item" \
        3.2 T "Down   Select next item" \
        3.2 T "+      Expand selected item" \
        3.2 T " -     Collapse selected item" \
        3.2 T "M-+    Expand all items" \
        3.2 T "M--    Collapse all items" \
        3.2 T "s      Set option value or key attribute" \
        3.2 T "S      Set global option value" \
        3.2 T "w      Set window option value, for pane/window option" \
        3.2 T "d      Set an option or key to the default" \
        3.2 T "D      Set tagged options/keys to default" \
        3.2 T "u      Unset an option or unbind a key" \
        3.2 T "U      Unset tagged options and unbind tagged keys" \
        3.2 T "C-s    Search by name" \
        3.2 T "n      Repeat last search $forwards_hint" \
        3.5 T "N      Repeat last search backwards" \
        3.2 T "t      Toggle if item is tagged" \
        3.2 T "T      Tag no items" \
        3.2 T "C-t    Tag all items" \
        3.2 T "f      Enter a format to filter items" \
        3.2 T "v      Toggle option information" \
        3.2 T "Esc/q  Exit mode"
    menu_generate_part 2 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Keys for customize-mode"
menu_min_vers=3.2

if [ -n "$1" ]; then
    prev_menu="$(realpath "$1")"
fi

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/../.." && pwd)

no_auto_menu_handling=1 # delay processing of dialog, only source it for now

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/menu_handling.sh

# manually trigger dialog handling
do_menu_handling
