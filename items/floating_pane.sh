#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling floating pane
#
#   For basic move & resize use this diamond, lower-case move, upper-case resize
#
#       T
#      F G
#       V
#
#   Placement keys (q,w,e,a,s,d,z,x,c) centered on s, left-hand keyboard cluster.
#   Avoids numpad 5-centered logic which fails for keyboards without numpad.
#
#   The version next-3.8 is handled as 3.7z in order to not match 3.8
#   until it is released, so the below 3.7z will be replaced with 3.8 once
#   it is released
#

static_content() {
    set -- \
        0.0 M Left "Back to Main menu  $nav_home" "$cfg_main_menu"

    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    rrm="$runshell_reload_mnu"
    set -- \
        0.0 S \
        3.7 C n "New floating pane" "new-pane -c \"#{pane_current_path}\" $rrm" \
        0.0 S \
        3.7z C t "Move pane up" "move-pane -D -$cfg_floating_pane_incr_vertical $rrm" \
        3.7z C f "Move pane left" "move-pane -R -$cfg_floating_pane_incr_horizontal $rrm" \
        3.7z C g "Move pane right" "move-pane -R $cfg_floating_pane_incr_horizontal $rrm" \
        3.7z C v "Move pane down" "move-pane -D $cfg_floating_pane_incr_vertical $rrm" \
        0.0 S \
        3.7z C T "Reduce pane height" "resize-pane -D -$cfg_floating_pane_incr_vertical $rrm" \
        3.7z C F "Reduce pane width" "resize-pane -R -$cfg_floating_pane_incr_horizontal $rrm" \
        3.7z C G "Grow pane width" "resize-pane -R $cfg_floating_pane_incr_horizontal $rrm" \
        3.7z C V "Grow pane height" "resize-pane -D $cfg_floating_pane_incr_vertical $rrm" \
        0.0 S \
        3.7z C q "Move pane top-left" "move-pane -P top-left $rrm" \
        3.7z C w "Move pane top-centre" "move-pane -P top-centre $rrm" \
        3.7z C e "Move pane top-right" "move-pane -P top-right $rrm" \
        3.7z C a "Move pane centre-left" "move-pane -P centre-left $rrm" \
        3.7z C s "Move pane centre" "move-pane -P centre $rrm" \
        3.7z C d "Move pane centre-right" "move-pane -P centre-right $rrm" \
        3.7z C z "Move pane bottom-left" "move-pane -P bottom-left $rrm" \
        3.7z C x "Move pane bottom-centre" "move-pane -P bottom-centre $rrm" \
        3.7z C c "Move pane bottom-right" "move-pane -P bottom-right $rrm" \
        0.0 S \
        0.0 M H "Help               $nav_next" "$d_help/help_floating_pane.sh $0"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Handling Floating Pane"
menu_min_vers=3.7z

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/.." && pwd)

[ "$($TMUX_BIN display -p '#{pane_floating_flag}')" = 1 ] || {
    . "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh
    tmux_vers_check 3.7z && {
        error_msg "'$menu_name' - Can only be used when a floating pane is focused"
    }
}

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/menu_handling.sh
