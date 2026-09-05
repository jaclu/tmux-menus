#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Place floating pane to pre-determined locations of window
#
#   Placement keys (q,w,e,a,s,d,z,x,c) centered on s, left-hand keyboard cluster.
#   Avoids numpad 5-centered logic which fails for keyboards without numpad.
#
#   The version next-3.8 is handled as 3.7z in order to not match 3.8
#   until it is released, so the below 3.7z will be replaced with 3.8 once
#   it is released
#

dynamic_content() {

    _dy_idx=4

    filt_all_other_floating_panes='#{?pane_floating_flag,#{?pane_active,0,1},0}'
    other_floating_panes=$($TMUX_BIN list-panes -F '#{pane_id}' \
        -f "$filt_all_other_floating_panes" | sort -t '%' -k 2 -n)
    if [ -n "$other_floating_panes" ]; then
        set -- \
            3.7z E p "previous floating pane" "$d_scripts/floating_pane_switch.sh previous \; $0" \
            3.7z E o "next floating pane" "$d_scripts/floating_pane_switch.sh next \; $0"
        menu_generate_part "$_dy_idx" "$@"
    else
        menu_generate_part "$_dy_idx" # clear prev entry
    fi
}

static_content() {
    _rrm="$runshell_reload_mnu"

    set -- \
        0.0 M Left "Back to Floating Pane  $nav_prev" floating_pane.sh \
        0.0 M Home "Back to Main menu      $nav_home" "$cfg_main_menu"

    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        3.7 C n "New floating pane" \
        "new-pane -c \"#{pane_current_path}\" $_rrm"
    menu_generate_part 3 "$@"

    set -- \
        0.0 S \
        3.7z C q "Move pane top-left" "move-pane -P top-left $_rrm" \
        3.7z C w "Move pane top-centre" "move-pane -P top-centre $_rrm" \
        3.7z C e "Move pane top-right" "move-pane -P top-right $_rrm" \
        3.7z C a "Move pane centre-left" "move-pane -P centre-left $_rrm" \
        3.7z C s "Move pane centre" "move-pane -P centre $_rrm" \
        3.7z C d "Move pane centre-right" "move-pane -P centre-right $_rrm" \
        3.7z C z "Move pane bottom-left" "move-pane -P bottom-left $_rrm" \
        3.7z C x "Move pane bottom-centre" "move-pane -P bottom-centre $_rrm" \
        3.7z C c "Move pane bottom-right" "move-pane -P bottom-right $_rrm" \
        0.0 S \
        0.0 M H "Help               $nav_next" "$d_help/h_floating_placement.sh $0"
    menu_generate_part 5 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Floating Pane - Placement"
menu_min_vers=3.7z

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/.." && pwd)

#
# Since env has not yet been loaded, some extra init is needed for this refusal
# if focused pane is not a floating pane
#
TMUX_BIN="${TMUX_BIN:-tmux}"
[ "$($TMUX_BIN display -p '#{pane_floating_flag}')" = 1 ] || {
    . "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh
    tmux_vers_check 3.7z && {
        error_msg "'$menu_name' - Can only be used when a floating pane is focused"
    }
}

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/menu_handling.sh
