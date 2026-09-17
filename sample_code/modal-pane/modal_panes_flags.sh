#!/bin/sh
#
#   Copyright (c) 2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Modal panes flags - explore -O, -K, and -C options
#

static_content() {
    set -- \
        0.0 M Home "Back to Main      $nav_home" "$cfg_main_menu" \
        0.0 M H "Help              $nav_next" \
        "$cfg_d_menus/help/h_modal_panes_flags.sh $0"
    menu_generate_part 1 "$@"
    display_commands_toggle 2

    set -- \
        0.0 S \
        3.8 T "-O: Create modal (blocks background):" \
        3.8 C o "Basic modal (prefix exits)" \
        "new-pane -O 'echo Modal pane. Press prefix to exit.'" \
        3.8 C m "Modal with message" \
        "new-pane -O 'echo You are in a modal pane - prefix to exit; sleep 3'" \
        0.0 S \
        3.8 T "-K: Pass all keys (no prefix interception):" \
        3.8 C K "Shell with all keys passed" \
        "new-pane -O -K 'sh'" \
        3.8 C s "Script with unrestricted input" \
        "new-pane -O -K 'cat > /tmp/input.txt'" \
        0.0 S \
        3.8 T "-C: Close on outside click:" \
        3.8 C c "Modal closes when clicked outside" \
        "new-pane -O -C 'echo Click outside to close; sleep 5'" \
        3.8 C e "Editor with click close" \
        "new-pane -O -C 'vim'" \
        0.0 S \
        3.8 T "-K and -C combined:" \
        3.8 C b "Full control (keys + click close)" \
        "new-pane -O -K -C 'sh'" \
        3.8 C f "fzf (selection with click close)" \
        "new-pane -O -K -C 'fzf'" \
        3.8 C d "Dialog (key + click interaction)" \
        "new-pane -O -K -C 'read -p \"Enter text: \" text'"
    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Modal Flags"
menu_min_vers=3.8

# shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
. "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh
