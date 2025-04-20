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

extract_key_bind() {
    #
    #  If a single key bind matches:           <prefix> K
    #  if it is non-prefix (-T root) key bind: <NO prefix> M-S-Up
    #  multiple binds are shown as:            <prefix> K  or  <prefix> C-Up
    #  No matches: return empty string
    #
    ekb_key_type="$1"
    ekb_cmd="$2"

    case "$ekb_key_type" in
    prefix) ekb_pref_str="<prefix>" ;;
    root) ekb_pref_str="<NO prefix>" ;;
    *) error_msg "extract_key_bind($ekb_key_type) - first param must be prefix or root" ;;
    esac
    [ -z "$ekb_cmd" ] && {
        error_msg "extract_key_bind($ekb_key_type, $ekb_cmd) - second param empty"
    }

    $TMUX_BIN list-keys | grep -iv mouse | grep "$ekb_cmd\$" |
        awk -v target="$ekb_key_type" -v label="$ekb_pref_str" '
        $0 ~ "-T[ ]*" target {
            for (i = 1; i <= NF; i++) {
                if ($i == target && i < NF) {
                    keys[++count] = $(i+1)
                    break
                }
            }
        }
        END {
            if (count == 1) {
                print label " " keys[1]
            } else if (count > 1) {
                for (i = 1; i <= count; i++) {
                    printf "%s %s%s", label, keys[i], (i < count ? "  or  " : "\n")
                }
            }
        }
    '
}

filter_bind_escapes() {
    #
    # Filter out \ prefix on key binds.
    # In some cases the \ needs to be kept for a key sequence in order
    # for it to be displayed in a menu, in such cases the menu will filter out
    # the prefix, so that it is not displayed
    #
    flc_input="$1"
    flc_last_char=$(expr "$flc_input" : '.*\(.\)$')
    log_it "><> flc_last_char [$flc_last_char]"

    case "$flc_last_char" in
    ';' | '"')
        # Some characters needs to be prefixed in order to be displayed in a menu
        echo "$flc_input"
        ;;
    *)
        # Extract \ char prefix from <Prefix> listigs
        echo "$flc_input" | sed 's/\\//g'
        ;;
    esac
}

check_key_binds() {
    #
    #  If a '-T prefix' or '-T root' key bind matches, display the key bind
    #  otherwise display the original command.
    #  Please note, if a prefix bind is found, no check for root binds are done
    #
    ckb_cmd="$1"
    log_it "check_key_binds($ckb_cmd)"

    # remove tmux bin, since that would make it
    ckb_no_tmux_bin="$(echo "$ckb_cmd" | sed "s#^$TMUX_BIN ##")"

    ckb_prefix_bind="$(extract_key_bind prefix "$ckb_no_tmux_bin")"
    if [ -n "$ckb_prefix_bind" ]; then
        filter_bind_escapes "$ckb_prefix_bind"
    else
        ckb_root_bind="$(extract_key_bind root "$ckb_no_tmux_bin")"
        if [ -n "$ckb_root_bind" ]; then
            filter_bind_escapes "$ckb_root_bind"
        else
            echo "$ckb_cmd"
        fi
    fi
}

show_cmd() {
    #
    # First filter out menu_reload components if present
    # then try to match command to a prefix key-bind. If a match is foond
    # display the prefix sequence matching the cmd, otherwise display the command uses
    #
    #  Feeding the menu creation via calls to mnu_text_line()
    #
    _s1="${1%" $menu_reload"}"             # skip menu_reload suffix if found
    _s2="${_s1%" $reload_in_runshell"}"    # skip reload_in_runshell suffix if found
    _s3="${_s2%"; $0"}"                    # Remove trailing reload of menu
    _s4="$(echo "$_s3" | sed 's/\\&.*//')" # skip hint overlays, ie part after \&
    # reduce excessive white space
    sc_cmd=$(printf '%s\n' "$_s4" | awk '{$1=$1; print}')
    log_it "show_cmd($sc_cmd)"

    [ -z "$sc_cmd" ] && error_msg "show_cmd() - no command could be extracted"
    sc_cmd="$(check_key_binds "$sc_cmd")"

    #
    #  Line break cmd if needed, to fit inside the menu width
    #  then calls mnu_text_line() for each line of the command to be displayed
    #
    sc_remainder="$sc_cmd"
    while [ -n "$sc_remainder" ]; do
        chunk=$(printf '%s\n' "$sc_remainder" | awk -v max="$cfg_display_cmds_cols" '
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

        sc_remainder=${sc_remainder#"$chunk"}
        sc_remainder=${sc_remainder#" "}
    done
    # refresh it for each cmd processed in case
    tmux_error_handler display-message "preparing TMUX_MENUS_SHOW_CMDS ..."
}
