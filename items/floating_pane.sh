#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling floating pane
#
#   Move / resize panes with this diamond:
#
#        t
#      f   g
#        v
#

dynamic_content() {
    #
    # menu_idx used, empty if no floating pane is present:
    #  2 navigate to floating_placement.sh, prev, next & Help
    #  5 Floating pane manipulation
    #
    case "$current_pane_is_floating" in
        0)                           # clear items
            menu_generate_part 2 0 D # dummy allows next item to be considered
            menu_generate_part 5     # non-item prevents 6 and on from being considered
            ;;
        1)
            # Only use this part if current is a floating pane

            set -- \
                3.8 M P "Placement         $nav_next" floating_placement.sh \
                3.8 M H "Help              $nav_next" \
                "$d_help/h_floating_pane.sh $0"
            menu_generate_part 2 "$@"

            if [ -n "$other_floating_panes" ]; then
                set -- \
                    3.7 E p "Previous" "$scr_float_pane_switch  previous \; $0" \
                    3.7 E n "Next" "$scr_float_pane_switch  next \; $0"

            else
                set -- 0 D
            fi
            menu_generate_part 5 "$@"

            # rest to static 6 ??

            ;;
        *) error_msg "Invalid value for pane_floating_flag [$current_pane_is_floating]" ;;
    esac
}

static_content() {
    set -- \
        0.0 M Left "Back to Previous  $nav_prev" panes.sh \
        0.0 M Home "Back to Main      $nav_home" "$cfg_main_menu"
    menu_generate_part 1 "$@"
    display_commands_toggle 3

    set -- \
        0.0 S

    [ -d "$d_cache" ] && {
        # Combined option unless cache is disabled
        _combo_menu="$d_items"/floating_pane_combined.sh
        set -- "$@" \
            3.7 E c "Use Combined Menu" "rm -f '$f_max_25_line_menus' \; $_combo_menu"
    }

    set -- "$@" \
        3.7 C N "New" \
        "new-pane -c \"#{pane_current_path}\" $runshell_sleep_reload_mnu"
    menu_generate_part 4 "$@"

    # shorter variablenames to avoid too long lines
    _vert_step="$cfg_floating_pane_incr_vertical"
    _hori_step="$cfg_floating_pane_incr_horizontal"
    _rrm="$runshell_reload_mnu"

    # focus is on a floating pane, primary actions relevant
    set -- \
        3.8 S \
        3.8 C t "Move up" "move-pane -D -$_vert_step $_rrm" \
        3.8 C v "Move down" "move-pane -D $_vert_step $_rrm" \
        3.8 C f "Move left" "move-pane -R -$_hori_step $_rrm" \
        3.8 C g "Move right" "move-pane -R $_hori_step $_rrm" \
        3.8 S \
        3.8 C T "Reduce height" "resize-pane -D -$_vert_step $_rrm" \
        3.8 C V "Grow height" "resize-pane -D $_vert_step $_rrm" \
        3.8 C F "Reduce width" "resize-pane -R -$_hori_step $_rrm" \
        3.8 C G "Grow width" "resize-pane -R $_hori_step $_rrm" \
        1.8 S \
        1.8 C K "${cfg_danger_zone}Kill current" "confirm-before -p \
            'kill-pane #T (#P)? (y/n)' kill-pane $runshell_reload_mnu"
    menu_generate_part 6 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Handling Floating Panes"
menu_min_vers=3.7

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/.." && pwd)

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/helpers_floating_pane.sh
floating_pane_focus

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/menu_handling.sh
