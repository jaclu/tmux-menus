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
    rld_cmd="command-prompt -I '$cfg_tmux_conf' -p 'Source file:' \
        'run-shell \"$d_scripts/reload_conf.sh %%\"'"

    set --

    if $cfg_use_cache && [ -f "$f_custom_items_index" ]; then
        set -- "$@" \
            0.0 M \+ "Custom items      $nav_next" "$f_custom_items_index"
    fi

    tmux_vers_check 3.2 && {
        customize_mode_cmd="$TMUX_BIN customize-mode -Z "
        if $cfg_use_hint_overlays && ! $cfg_use_whiptail; then
            # log_it "hint overlays and not whiptail"
            hint="\& $d_hints/customize-mode.sh skip-oversized"
            customize_mode_cmd="$customize_mode_cmd $hint"
        fi
    }

    set -- "$@" \
        1.7 M N "Navigate & Search  $nav_next" nav_search.sh \
        0.0 M P "handling Pane      $nav_next" panes.sh \
        0.0 M W "handling Window    $nav_next" windows.sh \
        0.0 M S "handling Sessions  $nav_next" sessions.sh \
        0.0 M B "paste Buffers      $nav_next" paste_buffers.sh \
        2.0 M M "Missing keys       $nav_next" "$d_odd_chars"/missing_keys.sh \
        0.0 M A "Advanced options   $nav_next" advanced.sh \
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

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
