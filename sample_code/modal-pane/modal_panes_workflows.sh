#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Modal panes workflows - real-world use cases and demonstrations
#

static_content() {
    set -- \
        0.0 M Home "Back to Main      $nav_home" "$cfg_main_menu" \
        0.0 M H "Help              $nav_next" \
        "$d_help/h_modal_panes_workflows.sh $0"
    menu_generate_part 1 "$@"
    display_commands_toggle 2

    set -- \
        0.0 S \
        3.8 T "Git workflows:" \
        3.8 C r "Interactive rebase (last 5)" \
        "new-pane -O 'git rebase -i HEAD~5'" \
        3.8 C a "Interactive add" \
        "new-pane -O 'git add -i'" \
        3.8 C l "Log viewer" \
        "new-pane -O 'git log --oneline -20'"
    menu_generate_part 3 "$@"

    set -- \
        0.0 S \
        3.8 T "Selection tools:" \
        3.8 C f "fzf file browser" \
        "new-pane -O -K 'fzf'" \
        3.8 C p "fzf with preview" \
        "new-pane -O -K 'fzf --preview=\"head -20 {}\"'" \
        3.8 C t "tree directory view" \
        "new-pane -O 'tree -L 3'"
    menu_generate_part 4 "$@"

    set -- \
        0.0 S \
        3.8 T "Editors and input:" \
        3.8 C v "vim" \
        "new-pane -O 'vim'" \
        3.8 C n "nano" \
        "new-pane -O 'nano'" \
        3.8 C e "Shell editor (EDITOR)" \
        "new-pane -O -K \"\${EDITOR:-vi}\"" \
        3.8 C m "Man page viewer" \
        "new-pane -O 'man tmux'"
    menu_generate_part 5 "$@"

    set -- \
        0.0 S \
        3.8 T "Development:" \
        3.8 C b "Build process" \
        "new-pane -O 'make'" \
        3.8 C d "Database shell" \
        "new-pane -O 'psql'" \
        3.8 C s "Python shell" \
        "new-pane -O 'python3'" \
        3.8 C i "Interactive shell" \
        "new-pane -O -K 'sh'"
    menu_generate_part 6 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Modal Workflows"
menu_min_vers=3.8

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh
