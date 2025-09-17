#!/bin/sh
#
#  Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  Template for Custom item, copy this into custom_items and modify it!
#

static_content() {

    set -- \
        0.0 M Left "Back to Custom items  $nav_prev" "$f_custom_items_index" \
        0.0 M Home "Back to Main menu     $nav_home" main.sh \
        0.0 S \
        0.0 T "*** Replace this line with one or more lines of custom contnent! ***"

    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="My Custom Menu"

# A custom items menu must define a menu_key, that will be its shortcut in the
# index listing custom items.
# Since this will be used to point to this menu from the index,
# it is recommended to use uppercase in order to follow the conventions
# in this plugin, but anything goes!
# If a "special" char is used it might need to be prefixed with \
# shellcheck disable=SC2034 # used in update_custom_inventory.sh
menu_key="?"

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd -- "$(dirname -- "$0")/.." && pwd)

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
