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

    fw_span="windows"
    # 2.5 - only window
    tmux_vers_compare 2.6 && fw_span="sessions & $fw_span"

    fw_lbl_line2=" only visible part"
    if tmux_vers_compare 3.2; then
        #  adds ignore case, and zooms the pane
        fw_lbl_line2="$fw_lbl_line2, ignores case"
        fw_flags="-Zi "
    elif tmux_vers_compare 2.9; then
        #  zooms the pane
        fw_flags="-Z"
    else
        fw_flags=""
    fi
    fw_cmd="command-prompt -p 'Search for:' 'find-window $fw_flags %%'"

    if [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
        #
        #  I must be misisng something, why would it be so hard to do this
        #  in whiptail?? I even had to create a custom cmd, and add a keep
        #  feature, so that whiptail cmds can be hardcoded without the
        #  default handling that works in all simpler cases
        #
        rld_cmd="echo $f_current_script > $f_wt_reload_script ;  \
            $TMUX_BIN command-prompt -I '$cfg_tmux_conf' -p 'Source file:' \
            'run-shell \"$d_scripts/reload_conf.sh %% >/dev/null\"'"
    else
        rld_cmd="command-prompt -I '$cfg_tmux_conf' -p 'Source file:' \
        'run-shell \"$d_scripts/reload_conf.sh %% $reload_in_runshell\"'"
    fi

    # 12.0 M S
    #  Menu items definition
    set -- \
        0.0 M P "Handling Pane     -->" panes.sh \
        0.0 M W "Handling Window   -->" windows.sh \
        0.0 M S "Handling Sessions -->" sessions.sh \
        1.8 M B "Paste buffers     -->" paste_buffers.sh \
        0.0 M L "Layouts           -->" layouts.sh \
        0.0 M V "Split view        -->" split_view.sh \
        2.0 M M "Missing Keys      -->" missing_keys.sh \
        0.0 M A "Advanced Options  -->" advanced.sh \
        0.0 M E "Extras            -->" extras.sh \
        0.0 S \
        0.0 C l "toggle status Line" "set status $menu_reload" \
        1.8 E p "Plugins inventory" "$d_scripts/plugins.sh" \
        1.7 S \
        1.8 C n "Navigate & select ses/win/pane" "$choose_tree_cmd" \
        1.7 T "-#[nodim]Search in all $fw_span" \
        1.7 C s "$fw_lbl_line2" "$fw_cmd" \
        0.0 S \
        0.0 C r "Reload configuration file" "$rld_cmd" keep \
        0.0 S \
        0.0 C d '<P> Detach from tmux' detach-client \
        0.0 S \
        0.0 M H 'Help -->' "$d_items/help.sh $f_current_script"

    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(realpath -- "$(dirname -- "$(dirname -- "$0")")")"

# shell check source=scripts/utils.sh
# . "$D_TM_BASE_PATH"/scripts/utils.sh  # needed for log_it before dialog_handling
# log_it "><> $current_script starting [$?]"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

e="$?"
if [ "$e" -ne 0 ]; then
    log_it "><> $current_script exiting [$e]"
fi
