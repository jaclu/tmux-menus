#!/bin/sh
#
#  Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  Main menu, the one popping up when you hit the trigger
#

static_content() {
    customize_mode_cmd="$TMUX_BIN customize-mode -Z "
    if ! $cfg_use_whiptail; then
        customize_mode_cmd="$customize_mode_cmd & $d_hints/customize-mode.sh  skip-oversized"
    fi
    rld_cmd="command-prompt -I '$cfg_tmux_conf' -p 'Source file:' \
        'run-shell \"$d_scripts/reload_conf.sh %% $reload_in_runshell\"'"

    [ -f "$f_custom_items_index" ] && {
        set -- \
            0.0 M \+ "Custom items $nav_next" "$f_custom_items_index"

        menu_generate_part 1 "$@"
    }

    #  Menu items definition
    set -- \
        1.8 M N "Navigate & Search $nav_next" nav_search.sh \
        0.0 M P "Handling Pane     $nav_next" panes.sh \
        0.0 M W "Handling Window   $nav_next" windows.sh \
        0.0 M S "Handling Sessions $nav_next" sessions.sh \
        1.8 M B "Paste buffers     $nav_next" paste_buffers.sh \
        0.0 M L "Layouts           $nav_next" layouts.sh \
        0.0 M V "Split view        $nav_next" split_view.sh \
        2.0 M M "Missing Keys      $nav_next" missing_keys.sh \
        0.0 M A "Advanced Options  $nav_next" advanced.sh \
        0.0 M E "Extras            $nav_next" extras.sh \
        0.0 S \
        3.2 T "-#[nodim]On-the-Fly Config" \
        3.2 E c "  (customize-mode)" "$customize_mode_cmd" \
        1.8 E p "Plugins inventory" "plugins.sh" \
        0.0 C p "Reload tmux conf" "$rld_cmd" \
        0.0 C d 'Detach from tmux' detach-client \
        0.0 S \
        3.2 T "-#[nodim]Key hints - " \
        3.2 M C "  customize-mode $nav_next" \
        "$d_hints/customize-mode.sh $f_current_script" \
        0.0 M H "Help             $nav_next" \
        "$d_help/help_summary.sh $f_current_script"

    menu_generate_part 2 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Main menu"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
