#!/bin/sh
#
#  Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  Template used for custom_items/_index.sh
#

static_content() {
    set -- \
        0.0 M Left "Back to Main menu $nav_home" main.sh \
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

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd -- "$(dirname -- "$0")/.." && pwd)

. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
