#!/bin/sh
#
#  Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  Main menu, the one popping up when you hit the trigger
#

static_content() {
    menu_name="Main menu"
    req_win_width=38
    req_win_height=24

    choose_tree_cmd="choose-tree"
    if tmux_vers_compare 2.7; then
        #  zooms the pane
        choose_tree_cmd="$choose_tree_cmd -Z"
    fi

    fw_label_cont=" only visible part"
    if tmux_vers_compare 3.2; then
        #  adds ignore case, and zooms the pane
        fw_label_cont="$fw_label_cont, ignores case"
        fw_flags="-Zi "
    elif tmux_vers_compare 2.9; then
        #  zooms the pane
        fw_flags="-Z"
    else
        fw_flags=""
    fi
    fw_cmd="command-prompt -p 'Search for:' 'find-window $fw_flags %%'"

    #  Menu items definition
    set -- \
        0.0 M P "Handling Pane     -->" panes.sh \
        0.0 M W "Handling Window   -->" windows.sh \
        2.0 M S "Handling Sessions -->" sessions.sh \
        1.8 M B "Paste buffers     -->" paste_buffers.sh \
        0.0 M L "Layouts           -->" layouts.sh \
        0.0 M V "Split view        -->" split_view.sh \
        2.0 M M "Missing Keys      -->" missing_keys.sh \
        0.0 M A "Advanced Options  -->" advanced.sh \
        0.0 M E "Extras            -->" extras.sh \
        0.0 S \
        0.0 C l "toggle status Line" "set status" \
        0.0 E p "Plugins inventory" "$D_TM_SCRIPTS/plugins.sh" \
        0.0 S \
        0.0 C n "Navigate & select ses/win/pane" "$choose_tree_cmd" \
        0.0 T "-#[nodim]Search in all sessions & windows" \
        0.0 C s "$fw_label_cont" "$fw_cmd" \
        0.0 S \
        0.0 E r 'Reload configuration file' reload_conf.sh \
        0.0 S \
        0.0 C d '<P> Detach from tmux' detach-client \
        0.0 S \
        0.0 M H 'Help -->' "$D_TM_ITEMS/help.sh $current_script"

    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath -- "$(dirname -- "$(dirname -- "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
