#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Handling floating pane
#
#   The version next-3.8 is handled as 3.7z in order to not match 3.8
#   until it is released, so the below 3.7z will be replaced with 3.8 once
#   it is released
#

dynamic_content() {
    #
    # menu_idx used, empty if no floating pane is present:
    #  2 navigate to floating_placement.sh, prev, next & Help
    #  5 Floating pane manipulation
    #  6 dummy to allow 7 to be used
    case "$current_pane_is_floating" in
        0)                           # clear items
            menu_generate_part 2 0 D # dummy allows next item to be considered
            menu_generate_part 5     # non-item prevents 6 and on from being considered
            ;;
        1)
            # Only use this part if current is a floating pane

            set -- \
                3.7z M H "Help              $nav_next" \
                "$d_help/h_floating_pane_combined.sh $0"
            menu_generate_part 2 "$@"

            if [ -n "$other_floating_panes" ]; then
                set -- \
                    3.7 E p "Previous" "$scr_float_pane_switch  previous \; $0" \
                    3.7 E n "Next" "$scr_float_pane_switch  next \; $0"
            else
                set -- 0 D
            fi
            menu_generate_part 5 "$@"
            ;;
        *) error_msg "Invalid value for pane_floating_flag [$current_pane_is_floating]" ;;
    esac
}

# 1 Navigation back
# 2 navigate to floating_placement.sh, prev, next & Help
# 3 display_commands_toggle (optional otherwise dummy)
# 4 actions
# 3 move
# 4 resize
# 5 Floating pane manipulation
# 7 placement

static_content() {
    set -- \
        0.0 M Left "Back to Previous  $nav_prev" panes.sh \
        0.0 M Home "Back to Main      $nav_home" "$cfg_main_menu"
    menu_generate_part 1 "$@"
    display_commands_toggle 3

    set -- \
        0.0 S

    [ -d "$d_cache" ] && {
        # Height compatibility option unless cache is disabled
        set -- "$@" \
            3.7 E l "Fit to 25 Lines" "touch '$f_max_25_line_menus' \; $0"
    }

    _new_pane="new-pane -c '#{pane_current_path}'"
    tmux_vers_check 3.8 && _new_pane="$_new_pane -A" # does not unzoom window

    set -- "$@" \
        3.7 C N "New" \
        "$_new_pane $runshell_sleep_reload_mnu"
    menu_generate_part 4 "$@"

    #
    # If not floating panes, there is no item 5, so item 6 below is skipped
    # this speeds up things a lot since this can be statically cached
    #

    # shorter variablenames to avoid too long lines
    _vert_step="$cfg_floating_pane_incr_vertical"
    _hori_step="$cfg_floating_pane_incr_horizontal"
    _rrm="$runshell_reload_mnu"

    set -- \
        3.7z S \
        3.7z C t "Move up" "move-pane -D -$_vert_step $_rrm" \
        3.7z C v "Move down" "move-pane -D $_vert_step $_rrm" \
        3.7z C f "Move left" "move-pane -R -$_hori_step $_rrm" \
        3.7z C g "Move right" "move-pane -R $_hori_step $_rrm" \
        3.7z S \
        3.7z C T "Reduce height" "resize-pane -D -$_vert_step $_rrm" \
        3.7z C V "Grow height" "resize-pane -D $_vert_step $_rrm" \
        3.7z C F "Reduce width" "resize-pane -R -$_hori_step $_rrm" \
        3.7z C G "Grow width" "resize-pane -R $_hori_step $_rrm" \
        3.7z S \
        3.7z C q "Place top-left" "move-pane -P top-left $_rrm" \
        3.7z C w "Place top-centre" "move-pane -P top-centre $_rrm" \
        3.7z C e "Place top-right" "move-pane -P top-right $_rrm" \
        3.7z C a "Place centre-left" "move-pane -P centre-left $_rrm" \
        3.7z C s "Place centre" "move-pane -P centre $_rrm" \
        3.7z C d "Place centre-right" "move-pane -P centre-right $_rrm" \
        3.7z C z "Place bottom-left" "move-pane -P bottom-left $_rrm" \
        3.7z C x "Place bottom-centre" "move-pane -P bottom-centre $_rrm" \
        3.7z C c "Place bottom-right" "move-pane -P bottom-right $_rrm" \
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

menu_name="Handling Floating Panes (C)"
menu_min_vers=3.7

#  Full path to tmux-menux plugin, remember to do one /.. for each subfolder
D_TM_BASE_PATH=$(cd "${0%/*}/.." && pwd)

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/helpers_floating_pane.sh
floating_pane_focus

# Sourcing helpers_floating_pane sourced helpers_minimal,
# this ensures f_max_25_line_menus to be available.
# If caching is disabled, play it safe and always use split menus, since it can't be toggled
if [ -f "$f_max_25_line_menus" ]; then # Use split menus if hint is found
    # Switch to the not as tall split menus, fitting inside 25 rows
    "$D_TM_BASE_PATH"/items/floating_pane.sh
    exit 0
fi

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$D_TM_BASE_PATH"/scripts/menu_handling.sh
