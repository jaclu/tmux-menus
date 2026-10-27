#!/bin/sh
#
#  Copyright (c) 2025-2026: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  Template used for custom_items/_index.sh
#

static_content() {
    set -- \
        0.0 M Home "Main Menu     $nav_home" "$cfg_main_menu" \
        0.0 S \
        "CUSTOM_ITEMS_SPLITTER" # the list of custom items will be inserted here

    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Custom items index"

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh
