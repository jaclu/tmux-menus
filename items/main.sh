#!/bin/sh
#
#  Copyright (c) 2022-2026: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  Main menu, the one popping up when you hit the trigger
#
#   The version next-3.8 is stored as 3.7z in order to not match 3.8
#   until it is released, so the below 3.7z will be replaced with 3.8 once
#   it is releases
#

static_content() {
    rld_cmd="command-prompt -I '$cfg_tmux_conf' -p 'Source file:' \
        'run-shell \"$d_scripts/reload_conf.sh %%\"'"

    set --

    if $cfg_use_cache && [ -f "$f_custom_items_index" ]; then
        set -- "$@" \
            0.0 M \+ "Custom items      $nav_next" "$f_custom_items_index"
    fi

    tmux_vers_check 3.2 && {
        customize_mode_cmd="$TMUX_BIN customize-mode -Z "
        if $cfg_use_hint_overlays && ! $b_use_alt_handler; then
            # log_it "hint overlays and not whiptail"
            hint="\& $d_hints/customize-mode.sh skip-oversized"
            customize_mode_cmd="$customize_mode_cmd $hint"
        fi
    }

    set -- "$@" \
        0.0 M P "Handling Pane      $nav_next" panes.sh \
        3.7 M F "  Floating Pane    $nav_next" floating_pane.sh \
        0.0 M W "Handling Window    $nav_next" windows.sh \
        0.0 M S "Handling Sessions  $nav_next" sessions.sh \
        0.0 M B "Paste Buffers      $nav_next" paste_buffers.sh \
        1.7 M N "Navigate & Search  $nav_next" nav_search.sh \
        2.0 M M "Missing Keys       $nav_next" "$d_odd_chars"/missing_keys.sh \
        0.0 M A "Advanced Options   $nav_next" advanced.sh \
        0.0 M E "Extras             $nav_next" extras.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2 # give this its own menu part idx

    set -- \
        0.0 S \
        3.2 T "-#[nodim]On-the-Fly Config" \
        3.2 E c "  (customize-mode)" "$customize_mode_cmd"

    $cfg_use_hint_overlays && $cfg_show_key_hints && {
        set -- "$@" \
            3.2 T "-#[nodim]Key hints - " \
            3.2 M K "  customize-mode  $nav_next" \
            "$d_hints/customize-mode.sh $0"
    }
    set -- "$@" \
        1.8 E p "Plugins inventory" "$D_TM_BASE_PATH"/tools/plugins.sh \
        0.0 C r "Reload tmux conf" "$rld_cmd" \
        0.0 C d 'Detach from tmux' detach-client \
        0.0 S \
        0.0 M H "Help               $nav_next" \
        "$d_help/help_summary.sh $0"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Main menu"

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/.." && pwd)

# temp  profiling code to check performance
# [ "$profiling_sourced" != 1 ] && . "$D_TM_BASE_PATH"/scripts/utils/dbg_profiling.sh

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/menu_handling.sh

# profiling_display "after dialog_handling"
