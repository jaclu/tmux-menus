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
#  if the command is available using a key bind, display this instead of the cmd
#

key_table_replace_cmd() {
    #
    # If multiple key bindings matches, use the first.
    # Uses and potentially modifies the external variable: cmd_bare
    #
    log_it "key_table_replace_cmd($cmd_bare)"
    tbl_type="$1"
    [ -z "$tbl_type" ] && error_msg "key_table_replace_cmd() - no param"

    # Filters out any unwanted key binds
    _cmd="$(
        $TMUX_BIN list-keys |
            grep "\-T $tbl_type" |                     # Only keep $tbl_type
            grep -v display-menu |                     # filter out the default menus
            sed "s/-T $tbl_type/|/" | cut -d'|' -f 2 | # filters out part before -T $tbl_type
            grep "$cmd_bare\$" | head -n 1 |           # only keep first match ending in $cmd_bare
            awk '{ print $1 }'                         # display the bind without any whitespace
    )"

    [ -n "$_cmd" ] && {
        # Label the key binding type
        case "$tbl_type" in
        prefix) _cmd="<Prefix> $_cmd" ;;
        root) _cmd="[No Prefix] $_cmd" ;;
        *) error_msg "key_table_replace_cmd() - param must be prefix or root" ;;
        esac

        #
        # In some cases the \ needs to be kept for a prefix sequence in order
        # for it to be displayed in a menu, as those are displayed the
        # menu will filter out this remaining esc char so that it is not displayed
        #
        last_char=$(expr "$_cmd" : '.*\(.\)$')
        log_it "><> last_char [$last_char]"
        case "$last_char" in
        ';' | '"')
            # Some characters needs to remain prefixed in order to be displayed in a menu
            cmd_bare="$_cmd"
            log_it "><> keeping esc char: [$cmd_bare]"
            ;;
        *)
            # Extract \ char prefix
            cmd_bare="$(echo "$_cmd" | sed 's/\\//g')"
            ;;
        esac
        return 0
    }
    return 1
}

show_cmd() {
    #
    # First filter out menu_reload components if present
    # then try to match command to a key bind. If a match is foond
    # display the key bind matching the cmd, otherwise display the command
    #
    _s1="${1%" $menu_reload"}"             # skip menu_reload suffix if found
    _s2="${_s1%" $reload_in_runshell"}"    # skip reload_in_runshell suffix if found
    _s3="${_s2%"; $0"}"                    # Remove trailing reload of menu
    _s4="$(echo "$_s3" | sed 's/\\&.*//')" # skip hint overlays, ie part after \&
    # reduce excessive white space
    cmd_bare=$(printf '%s\n' "$_s4" | awk '{$1=$1; print}')

    log_it "show_cmd($cmd_bare)"
    [ -z "$cmd_bare" ] && error_msg "show_cmd() - no command could be extracted"

    # First see if there is a prefix match, if not check root table
    key_table_replace_cmd prefix || key_table_replace_cmd root

    cmd="$(echo "$cmd_bare" | sed 's/#/##/g')" # prevents tmux from expanding #{} constructs
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
