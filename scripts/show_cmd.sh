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
    log_it "prefix_replace_cmd($cmd_bare)"

    # $TMUX_BIN list-keys | grep -iv mouse | grep "$cmd_bare" | awk '{$1=""; sub(/^[ \t]+/, ""); print}'
    # $TMUX_BIN list-keys | grep -iv mouse | grep "$cmd_bare" | awk '{$1=""; sub(/^[ \t]+/, ""); print}'

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
    # First filter out menu_reload component if it is present
    # then try to match command to a prefix key-bind. If a match is foond
    # display the prefix sequence needed, otherwise describe the tmux command needed
    #
    _s1="${1%" $menu_reload"}"             # skip menu_reload suffix if found
    _s2="${_s1%" $reload_in_runshell"}"    # skip reload_in_runshell suffix if found
    _s3="${_s2%"; $0"}"                    # Remove trailing reload of menu
    _s4="$(echo "$_s3" | sed 's/\\&.*//')" # skip hint overlays, ie part after \&
    # reduce excessive whitespace
    cmd_bare=$(printf '%s\n' "$_s4" | awk '{$1=$1; print}')

    # printf '1: >>%s<<\n' "$1" >>"$cfg_log_file"
    # printf 'menu_reload: >>%s<<\n' "$menu_reload" >>"$cfg_log_file"
    # cmd="${1%$menu_reload}" # filter out trailing menu_reload

    log_it
    log_it "show_cmd($cmd_bare)"
    [ -z "$cmd_bare" ] && error_msg "show_cmd() - no command could be extracted"
    #$b_show_commands && return # keep it disabled for now

    prefix_replace_cmd

    cmd=$cmd_bare
    while [ -n "$cmd" ]; do
        chunk=$(printf '%.70s' "$cmd")
        log_it "  chunk: >>$chunk<<"
        mnu_text_line "  $chunk"
        cmd=${cmd#"$chunk"}
    done

    # mnu_text_line "$cmd_bare"
    # error_msg "cmd_bare [$cmd_bare]"
}
