#!/bin/sh
# This is sourced. Fake bang-path to help editors and linters
# shellcheck disable=SC2154
#
#   Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Add extra line in menu displaying what command an action would use
#  if the command is available using a prefix bind, display this instead of the cmd
#

prefix_replace_cmd() {
    # If a single prefix cmd matches display it as a prefix bind instead of command
    log_it "prefix_replace_cmd($cmd_bare)"

    _prefix_cmd="$($TMUX_BIN list-keys | grep -iv mouse | grep "$cmd_bare" |
        sed -n 's/^[^ ][^ ]*[ ][ ]*-T[ ][ ]*prefix[ ][ ]*\([^ ][^ ]*\).*/<Prefix> \1/p')"
    [ -n "$_prefix_cmd" ] && {
        # _lc="$(echo "$_prefix_cmd" | wc -l)"
        _lc=$(printf '%s' "$_prefix_cmd" | awk 'END{print NR}')
        [ "$_lc" != "1" ] && return # multiple prefix matches, display command as is

        #
        # In some cases the \ needs to be kept for a prefix sequence in order
        # for it to be displayed in a menu, as those are displayed the
        # menu will filter out this remaining esc char so that it is not displayed
        #
        last_char=$(expr "$_prefix_cmd" : '.*\(.\)$')
        log_it "><> last_char [$last_char]"
        case "$last_char" in
        ';' | '"')
            # Some characters needs to be prefixed in order to be displayed in a menu
            cmd_bare="$_prefix_cmd"
            log_it "><> keeping esc char: [$cmd_bare]"
            ;;
        *)
            # Extract \ char prefix from <Prefix> listigs
            cmd_bare="$(echo "$_prefix_cmd" | sed 's/\\//g')"
            ;;
        esac
    }
}

show_cmd() {
    #
    # First filter out menu_reload components if present
    # then try to match command to a prefix key-bind. If a match is foond
    # display the prefix sequence matching the cmd, otherwise display the command uses
    #
    _s1="${1%" $menu_reload"}"             # skip menu_reload suffix if found
    _s2="${_s1%" $reload_in_runshell"}"    # skip reload_in_runshell suffix if found
    _s3="${_s2%"; $0"}"                    # Remove trailing reload of menu
    _s4="$(echo "$_s3" | sed 's/\\&.*//')" # skip hint overlays, ie part after \&
    # reduce excessive white space
    cmd_bare=$(printf '%s\n' "$_s4" | awk '{$1=$1; print}')

    log_it "show_cmd($cmd_bare)"
    [ -z "$cmd_bare" ] && error_msg "show_cmd() - no command could be extracted"

    prefix_replace_cmd

    cmd="$cmd_bare"
    while [ -n "$cmd" ]; do
        chunk=$(printf '%s\n' "$cmd" | awk -v max="$cfg_display_cmds_cols" '
        {
            if (length($0) <= max) {
                print $0
            } else {
                for (i = max; i > 0; i--) {
                    if (substr($0, i, 1) ~ /[[:space:]]/) {
                        print substr($0, 1, i)
                        exit
                    }
                }
                # No space found, just cut at max
                print substr($0, 1, max)
            }
        }')

        log_it "  chunk: >>$chunk<<"
        mnu_text_line "-#[nodim]  $chunk"

        cmd=${cmd#"$chunk"}
        cmd=${cmd#" "}
    done
}
