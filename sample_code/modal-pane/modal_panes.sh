#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Modal panes - blocking overlay panes that prevent interaction with
#   background. Use cases: git rebase, fzf selection, editor workflows.
#   -O creates modal, -K passes all keys, -C closes on click outside.
#

static_content() {
    set -- \
        0.0 M Home "Back to Main      $nav_home" "$cfg_main_menu" \
        0.0 M H "Help              $nav_next" \
        "$cfg_d_menus/help/h_modal_panes.sh $0"
    menu_generate_part 1 "$@"
    display_commands_toggle 2

    set -- \
        0.0 S \
        3.8 T "Basic modal pane examples:" \
        3.8 C v "vim (editor)" \
        "new-pane -O 'vim'" \
        3.8 C g "git rebase -i" \
        "new-pane -O 'git rebase -i HEAD~5'" \
        3.8 C f "fzf (with key passthrough)" \
        "new-pane -O -K 'fzf'"
    menu_generate_part 3 "$@"

    set -- \
        0.0 S \
        3.8 T "With close-on-click (-C):" \
        3.8 C c "vim (close on outside click)" \
        "new-pane -O -C 'vim'"
    menu_generate_part 4 "$@"

    set -- \
        0.0 S \
        3.8 T "Both flags (-K -C):" \
        3.8 C b "fzf (pass keys + close click)" \
        "new-pane -O -K -C 'fzf'" \
        3.8 C s "Shell prompt" \
        "new-pane -O -K -C 'sh'"
    menu_generate_part 5 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Modal Panes"
menu_min_vers=3.8

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh
