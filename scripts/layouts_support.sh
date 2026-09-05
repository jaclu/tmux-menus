#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Support functions for layout scripts.sh
#

handle_layout_border_lines() {
    # Display if the current setting is local (this window) or global
    # Set this as a window option
    hlbl_opt="$1"
    log_it "><> handle_pane_border_status($hlbl_opt)"

    [ -n "$hlbl_opt" ] || error_msg "handle_layout_border_lines() - no param"
    hlbl_lbl_single="Single"
    hlbl_lbl_rounded="Rounded"
    hlbl_lbl_double="Double"
    hlbl_lbl_heavy="Heavy"
    hlbl_lbl_simple="Simple"
    hlbl_lbl_padded="Padded"
    hlbl_lbl_number="Number"
    hlbl_lbl_spaces="Spaces"
    hlbl_lbl_none="None"

    hlbl_cmd="set-option -w $hlbl_opt" # only change on a per window basis
    hlbl_win_option="$($TMUX_BIN show-options -wv "$hlbl_opt")"
    hlbl_glob_option="$($TMUX_BIN show-options -gv "$hlbl_opt")"
    [ -z "$hlbl_win_option" ] && [ -z "$hlbl_glob_option" ] && {
        # only fall-back to global if there is any
        hlbl_win_option=single
    }
    case "$hlbl_win_option" in
        single) hlbl_lbl_single="-$hlbl_lbl_single" ;;
        rounded) hlbl_lbl_rounded="-$hlbl_lbl_rounded" ;;
        double) hlbl_lbl_double="-$hlbl_lbl_double" ;;
        heavy) hlbl_lbl_heavy="-$hlbl_lbl_heavy" ;;
        simple) hlbl_lbl_simple="-$hlbl_lbl_simple" ;;
        number) hlbl_lbl_number="-$hlbl_lbl_number" ;;
        spaces) hlbl_lbl_spaces="-$hlbl_lbl_spaces" ;;
        none) hlbl_lbl_none="-$hlbl_lbl_none" ;;
        "") # No win option - use global as current
            case "$hlbl_glob_option" in
                single) hlbl_lbl_single="-(global) $hlbl_lbl_single" ;;
                rounded) hlbl_lbl_rounded="-(global) $hlbl_lbl_rounded" ;;
                double) hlbl_lbl_double="-(global) $hlbl_lbl_double" ;;
                heavy) hlbl_lbl_heavy="-(global) $hlbl_lbl_heavy" ;;
                simple) hlbl_lbl_simple="-(global) $hlbl_lbl_simple" ;;
                # padded) ;; # popup-border-lines menu-border-lines
                number) hlbl_lbl_number="-(global) $hlbl_lbl_number" ;; # pane-border-lines
                spaces) hlbl_lbl_spaces="-(global) $hlbl_lbl_spaces" ;; # pane-border-lines
                none) hlbl_lbl_none="-(global) $hlbl_lbl_none" ;;
                *) error_msg "Unknown global option: $hlbl_opt [$hlbl_glob_option]" ;;
            esac
            ;;
        *) error_msg "Unknown win option: $hlbl_opt [$hlbl_win_option]" ;;
    esac

    # TODO: option none below did not work as per man page as late as 26-09-02
    #       disable is still broken by release
    hlbl_no_border="No border for floating panes"
    set -- \
        3.2 T "-" \
        3.2 T "-#[align=centre,nodim]pane-border-lines" \
        3.2 C s "$hlbl_lbl_single" "$hlbl_cmd  single  $runshell_reload_mnu"

    [ "$hlbl_opt" = "popup-border-lines" ] && {
        set -- "$@" \
            3.2 C s "$hlbl_lbl_rounded" "$hlbl_cmd  rounded  $runshell_reload_mnu"

    }

    set -- "$@" \
        3.2 C d "$hlbl_lbl_double" "$hlbl_cmd  double  $runshell_reload_mnu" \
        3.2 C h "$hlbl_lbl_heavy" "$hlbl_cmd  heavy   $runshell_reload_mnu" \
        3.2 C i "$hlbl_lbl_simple" "$hlbl_cmd  simple  $runshell_reload_mnu"

    case "$hlbl_opt" in
        popup-border-lines | menu-border-lines)
            set -- "$@" \
                3.2 C p "$hlbl_lbl_padded" "$hlbl_cmd  padded  $runshell_reload_mnu"
            ;;
        pane-border-lines)
            set -- "$@" \
                3.2 C \\# "$hlbl_lbl_number" "$hlbl_cmd  number  $runshell_reload_mnu" \
                3.6 C p "$hlbl_lbl_spaces" "$hlbl_cmd  spaces  $runshell_reload_mnu"
            ;;
        *) ;;
    esac

    set -- "$@" \
        3.7z C n "$hlbl_no_border" "$hlbl_cmd  none    $runshell_reload_mnu"
    menu_generate_part 5 "$@" #
}

#===============================================================
#
#   Main
#
#===============================================================

if false; then
    # Shellcheck analyzes this code path but it never executes at runtime
    . tools/variables_meta.sh
fi
log_it "><> layouts_support.sh: init"
