#!/usr/bin/env bash
#
#   Copyright (c) 2021: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.0 2021-11-06-
#       Initial release
#

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#: "${show_help:=1}"

render_menu() {
    
    if [ "$show_help" -eq 1 ]; then
	items+=(
	    ""
	    "Help"  h  "run-shell \"$CURRENT_DIR/help.sh $CURRENT_DIR/$menu_name\""
	)  
    fi
    

    show_items_quoted() {
	for item in "${items[@]}"; do
	    echo -n "\"$item\" "
	done
	echo
    }
    

    echo "tmux display-menu -T \"#[align=centre] $menu_title \"  -x C -y C  $(show_items_quoted)"
}
