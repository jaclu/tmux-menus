#!/bin/sh
# Always sourced file - Fake bang path to help editors
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Support functions for multiple floating pane handling menus
#
#  Provides:
#   current_pane_is_floating 0/1
#   other_floating_panes     all non-focused floating panes, if any
#

define_other_floating_panes() {
    other_floating_panes=$($TMUX_BIN list-panes -F '#{pane_id}' \
        -f '#{?pane_floating_flag,#{?pane_active,0,1},0}' \
        | sort -t '%' -k 2 -n)
}

floating_pane_focus() {
    # switch focus to a floating pane if any visible

    [ "$current_pane_is_floating" != 1 ] && [ -n "$other_floating_panes" ] && {
        # If non-focused floating panes are present on the window, shift focus
        # to one of them first
        $scr_float_pane_switch next
        current_pane_is_floating=1 # now focused pane is a floating one
        define_other_floating_panes
    }
}

switch_floating_pane() {
    # Moves to next/prev floating pane on same window if any
    action="$1" # one of previous/next

    [ -z "$other_floating_panes" ] && {
        # return # nothing to do here
        error_msg "switch_floating_pane() called with no other floating pane visible"
    }

    this_pane=$($TMUX_BIN display -p '#{pane_id}')
    this_num=${this_pane#%}

    case "$action" in
        previous)
            # Switch to first item in other_floating_panes with id lower than
            # $this_pane - or last item, if none with lower id
            previous=
            last=

            for pane in $other_floating_panes; do
                num=${pane#%}

                last=$pane

                if [ "$num" -lt "$this_num" ]; then
                    previous=$pane
                fi
            done

            # Wrap around if none lower
            [ -n "$previous" ] || previous=$last

            $TMUX_BIN select-pane -t "$previous"
            ;;
        next)
            # switch to first item in other_floating_panes with higher id than
            # $this_pane - or first item, if none with higher id
            next=
            first=

            for pane in $other_floating_panes; do
                num=${pane#%}

                [ -n "$first" ] || first=$pane

                if [ "$num" -gt "$this_num" ]; then
                    next=$pane
                    break
                fi
            done

            # Wrap around if none higher
            [ -n "$next" ] || next=$first

            $TMUX_BIN select-pane -t "$next"
            ;;
        *) error_msg "Invalid action for switch_floating_pane()" ;;
    esac
}

#---------------------------------------------------------------
#
#   Components of floating-panes menu
#
# menu_idx use
#  1 - Move back
#  2 - Switch split/combined menu
#  3 - placemment & help displayed if current pane is floating, otherwise dummy
#  4 - Display Commands
#  5 - Spacer
#  6 - New floating pane
#  7 - nav displayed if more than one floating pane, otherwise dummy
#  8 - dummy if floater visible
#    - menu_section_move
#    - menu_section_resize
#    - menu_section_placement
#
#---------------------------------------------------------------

menu_section_base() {
    # menu_idx use
    #  1 - Move back
    #  4 - Display Commands
    #  5 - Spacer
    #  6 - Switch split/combined menu & New floating pane

    menu_type="$1"
    case "$0" in
        *placement.sh) _prev="$cfg_d_menus"/floating_pane.sh ;;
        *) _prev="panes.sh" ;;
    esac

    set -- \
        0.0 M Left "Back to Previous   $nav_prev" "$_prev" \
        0.0 M Home "Main Menu          $nav_home" "$cfg_main_menu"
    menu_generate_part 1 "$@"
    display_commands_toggle 4
    set -- 0.0 S
    menu_generate_part 5 "$@"

}

menu_section_help_nav() {
    #
    # Needs to be called from dynamic_content
    #
    # menu_idx use
    #  2 - Switch split/combined menu
    #  3 - placemment & help displayed if current pane is floating, otherwise dummy
    #  7 - nav displayed if more than one floating pane, otherwise dummy
    #  8 - dummy if floater visible
    #
    menu_type="$1"

    case "$menu_type" in
        combined)
            set -- \
                3.7 E 2 "Fit to 25 Lines    $nav_next" \
                "touch '$f_max_25_line_menus' ; '$cfg_d_menus'/floating_pane.sh"
            ;;
        *)
            set -- \
                3.7 E C "Use Combined Menu  $nav_next" \
                "rm -f '$f_max_25_line_menus' ; '$cfg_d_menus'/floating_pane_combined.sh"
            ;;
    esac
    menu_generate_part 2 "$@"

    set -- \
        1.8 S \
        3.7 C N "New" "$new_pane $runshell_sleep_reload_mnu"

    [ "$current_pane_is_floating" = 1 ] && {
        set -- "$@" \
            1.8 C K "${cfg_danger_zone}Kill current" "confirm-before -p \
                'kill-pane #T (#P)? (y/n)' kill-pane $runshell_reload_mnu"
        if tmux_vers_check 3.8 || [ -n "$other_floating_panes" ]; then
            set -- "$@" 1.8 S
        fi
    }
    menu_generate_part 6 "$@"

    case "$current_pane_is_floating" in
        0) # clear items
            menu_generate_part 3 0 D
            menu_generate_part 5 0 D
            menu_generate_part 7 0 D
            menu_generate_part 8
            ;;

        1) # Only use this part if current is a floating pane
            case "$0" in
                *placement.sh)
                    help_menu="h_floating_pane_placement.sh"
                    skip_placement=1
                    ;;
                *combined.sh) help_menu="h_floating_pane_combined.sh" ;;
                *) help_menu="h_floating_pane.sh" ;;
            esac

            if [ -f "$f_max_25_line_menus" ] && [ "$skip_placement" != 1 ]; then
                set -- \
                    3.8 M P "Placement          $nav_next" floating_pane_placement.sh
            else
                set --
            fi
            set -- "$@" \
                3.8 M H "Help               $nav_next" "$cfg_d_menus/help/$help_menu $0"
            menu_generate_part 3 "$@"

            #
            #  nav
            #
            if [ -n "$other_floating_panes" ]; then
                set -- \
                    3.7 E p "Previous" "$scr_float_pane_switch  previous ; $0" \
                    3.7 E n "Next" "$scr_float_pane_switch  next ; $0"
            else
                set -- 0 D # dummy allows next item to be considered
            fi
            menu_generate_part 7 "$@"

            menu_generate_part 8 0 D # dummy allows next item to be considered

            ;;
        *) error_msg "Invalid value for pane_floating_flag [$current_pane_is_floating]" ;;
    esac
}

menu_section_move() {
    _idx="$1"
    [ -n "$_idx" ] || error_msg "menu_section_move() - no item index"

    set -- \
        3.8 S \
        3.8 C t "Move up" "move-pane -D -$hfp_v_step  $runshell_reload_mnu" \
        3.8 C v "Move down" "move-pane -D $hfp_v_step  $runshell_reload_mnu" \
        3.8 C f "Move left" "move-pane -R -$hfp_h_step  $runshell_reload_mnu" \
        3.8 C g "Move right" "move-pane -R $hfp_h_step  $runshell_reload_mnu"
    menu_generate_part "$_idx" "$@"
}

menu_section_resize() {
    _idx="$1"
    [ -n "$_idx" ] || error_msg "menu_section_resize() - no item index"

    set -- \
        3.8 S \
        3.8 C T "Reduce height" "resize-pane -D -$hfp_v_step  $runshell_reload_mnu" \
        3.8 C V "Grow height" "resize-pane -D $hfp_v_step  $runshell_reload_mnu" \
        3.8 C F "Reduce width" "resize-pane -R -$hfp_h_step  $runshell_reload_mnu" \
        3.8 C G "Grow width" "resize-pane -R $hfp_h_step  $runshell_reload_mnu"

    menu_generate_part "$_idx" "$@"
}

menu_section_placement() {
    hfp_rrm="$runshell_reload_mnu"

    _idx="$1"
    [ -n "$_idx" ] || error_msg "menu_section_placement() - no item index"

    set -- \
        3.8 S \
        3.8 C q "Place top-left" "move-pane -P top-left  $hfp_rrm" \
        3.8 C w "Place top-centre" "move-pane -P top-centre  $hfp_rrm" \
        3.8 C e "Place top-right" "move-pane -P top-right  $hfp_rrm" \
        3.8 C a "Place centre-left" "move-pane -P centre-left  $hfp_rrm" \
        3.8 C s "Place centre" "move-pane -P centre  $hfp_rrm" \
        3.8 C d "Place centre-right" "move-pane -P centre-right  $hfp_rrm" \
        3.8 C z "Place bottom-left" "move-pane -P bottom-left  $hfp_rrm" \
        3.8 C x "Place bottom-centre" "move-pane -P bottom-centre  $hfp_rrm" \
        3.8 C c "Place bottom-right" "move-pane -P bottom-right  $hfp_rrm"

    menu_generate_part "$_idx" "$@"
}

#---------------------------------------------------------------
#
#   Components of floating-panes help menu
#
#---------------------------------------------------------------

help_section_base() {
    if [ -z "$prev_menu" ]; then
        error_msg "$bn_current_script was called without notice of what called it"
    fi
    set -- \
        0.0 M Left "Back to Previous    $nav_prev" "$prev_menu" \
        0.0 M Home "Main Menu           $nav_home" "$cfg_main_menu" \
        0.0 S
    menu_generate_part 1 "$@"
}

help_section_move_resize() {
    _idx="$1"
    [ -n "$_idx" ] || error_msg "help_section_move_resize() - no item index"

    set -- \
        0.0 T "Move / Resize - diamond pattern:" \
        0.0 T "" \
        0.0 T "           t (up)" \
        0.0 T " f (left)            g (right)" \
        0.0 T "           v (down)" \
        0.0 T "" \
        0.0 T "lowercase:  move" \
        0.0 T "UPPERCASE:  resize" \
        0.0 T ""
    menu_generate_part "$_idx" "$@"
}

help_section_placement() {
    _idx="$1"
    [ -n "$_idx" ] || error_msg "help_section_placement() - no item index"

    set -- \
        0.0 T "" \
        0.0 T "          q   w   e" \
        0.0 T "          a   s   d" \
        0.0 T "          z   x   c" \
        0.0 T "" \
        0.0 T "Key position = pane position," \
        0.0 T "with s placing it in the centre."
    menu_generate_part "$_idx" "$@"
}

help_section_be_aware() {
    _idx="$1"
    [ -n "$_idx" ] || error_msg "help_section_be_aware() - no item index"

    set -- \
        0.0 T "" \
        0.0 T "The menu closes and reopens on" \
        0.0 T "every key. Press one key, wait" \
        0.0 T "for it to redraw, then the next —" \
        0.0 T "anything typed in between goes" \
        0.0 T "straight into the pane."
    menu_generate_part "$_idx" "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

no_auto_menu_handling=1 # delay processing of dialog, only source it for now
[ "$menu_handling_sourced" != 1 ] && {
    # Only source if not done
    # shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
    . "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh
}

# f_floating_pane_combined="$cfg_d_menus"/floating_pane_combined.sh

# shorter variablenames to avoid too long lines
hfp_v_step="$cfg_floating_pane_incr_vertical"
hfp_h_step="$cfg_floating_pane_incr_horizontal"
hfp_rrm="$runshell_reload_mnu"

new_pane="new-pane -c '#{pane_current_path}'"
tmux_vers_check 3.8 && new_pane="$new_pane -A" # does not unzoom window

# Set up basic floating pane env
current_pane_is_floating=$($TMUX_BIN display -p '#{pane_floating_flag}')
define_other_floating_panes
