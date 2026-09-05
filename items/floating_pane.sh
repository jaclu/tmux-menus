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

dynamic_content() {
    _dy_idx=4

    tmux_vers_check 3.7 || return
    _is_floating=$($TMUX_BIN display -p '#{pane_floating_flag}')

    case "$_is_floating" in
        0) menu_generate_part "$_dy_idx" ;; # clear item
        1)
            # Only use this part if current is a floating pane
            # shorer variablenames to avoid to long lines
            _rrm="$runshell_reload_mnu"
            _vert_step="$cfg_floating_pane_incr_vertical"
            _hori_step="$cfg_floating_pane_incr_horizontal"

            filt_all_other_floating_panes='#{?pane_floating_flag,#{?pane_active,0,1},0}'
            other_floating_panes=$($TMUX_BIN list-panes -F '#{pane_id}' \
                -f "$filt_all_other_floating_panes" | sort -t '%' -k 2 -n)

            if [ -n "$other_floating_panes" ]; then
                set -- \
                    3.7 E p "previous floating pane" "$d_scripts/floating_pane_switch.sh previous \; $0" \
                    3.7 E o "next floating pane" "$d_scripts/floating_pane_switch.sh next \; $0"
            else
                set --
            fi

            # focus is on a floating pane, primary actions relevant
            set -- "$@" \
                3.7z S \
                3.7z C t "Move pane up" "move-pane -D -$_vert_step $_rrm" \
                3.7z C f "Move pane left" "move-pane -R -$_hori_step $_rrm" \
                3.7z C g "Move pane right" "move-pane -R $_hori_step $_rrm" \
                3.7z C v "Move pane down" "move-pane -D $_vert_step $_rrm" \
                3.7z S \
                3.7z C T "Reduce pane height" "resize-pane -D -$_vert_step $_rrm" \
                3.7z C F "Reduce pane width" "resize-pane -R -$_hori_step $_rrm" \
                3.7z C G "Grow pane width" "resize-pane -R $_hori_step $_rrm" \
                3.7z C V "Grow pane height" "resize-pane -D $_vert_step $_rrm" \
                3.7z S \
                3.7z M H "Help               $nav_next" "$d_help/h_floating_pane.sh $0"
            menu_generate_part "$_dy_idx" "$@"
            ;;
        *) error_msg "Invalid value for pane_floating_flag [$_is_floating]" ;;
    esac
}

static_content() {
    set -- \
        0.0 M Left "Back to Main menu   $nav_home" "$cfg_main_menu" \
        0.0 M P "Placement of pane      $nav_next" floating_placement.sh
    menu_generate_part 1 "$@"
    $cfg_display_cmds && display_commands_toggle 2

    set -- \
        0.0 S \
        3.7 C n "New floating pane" \
        "new-pane -c \"#{pane_current_path}\" $runshell_reload_mnu"

    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Handling Floating Pane"
menu_min_vers=3.7

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/.." && pwd)

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/menu_handling.sh
