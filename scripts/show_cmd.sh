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
    ekb_key_type="$1"
    ekb_cmd="$2"
    ekb_output_var="$3"

    # log_it "extract_key_bind($ekb_key_type, $ekb_cmd, $ekb_output_var)"

    [ -z "$ekb_cmd" ] && {
        error_msg "extract_key_bind($ekb_key_type, $ekb_cmd) - command empty"
    }

    [ ! -f "$f_cached_tmux_key_binds" ] && {
        error_msg "extract_key_bind() not found: $f_cached_tmux_key_binds"
    }

    keys=$(
        awk -v target="$ekb_key_type" -v cmd="$ekb_cmd" '
    {
        found_target = 0
        key_field = 0
        for (i = 1; i <= NF; i++) {
            if ($i == "-T" && (i+1) <= NF && $(i+1) == target) {
                found_target = 1
                key_field = i + 2
            }
        }

        if (found_target) {
            # Rebuild command string from the fields after the key
            cmd_start = key_field + 1
            actual_cmd = ""
            for (j = cmd_start; j <= NF; j++) {
                actual_cmd = actual_cmd (j == cmd_start ? "" : " ") $j
            }

            if (actual_cmd == cmd) {
                key = $(key_field)
                if (key == "*") {
                    print "\\" key
                } else {
                    print key
                }
            }
        }
    }
    ' "$f_cached_tmux_key_binds"
    )

    if [ -n "$ekb_output_var" ]; then
        eval "$ekb_output_var=\"\$keys\""
    else
        echo "$keys"
    fi
}

filter_bind_escapes_single() {
    # some bind chars are prefixed with \
    # this func removed them, except for a few special cases that must be escaped
    # in order to be displayed with display-menu.
    # For those chars, display-menu will unescape them.
    key=$1
    fbes_output_var="$2"
    last_char=$(printf '%s' "$key" | awk '{print substr($0,length,1)}')

    # log_it "filter_bind_escapes_single($key, $fbes_output_var) [$last_char]"
    [ -z "$fbes_output_var" ] && {
        error_msg "filter_bind_escapes_single() - missing param 2"
    }

    case "$last_char" in
    ';' | '"')
        # printf '%s\n' "$key"
        eval "$fbes_output_var=\"$key\""
        ;;
    *)
        # shellcheck disable=SC1003 # in this case it is actually POSIX-compliant
        clean_key=$(printf '%s' "$key" | tr -d '\\')
        # printf '%s\n' "$clean_key"
        eval "$fbes_output_var=\"$clean_key\""
        ;;
    esac
}

add_result() {
    # If multiple results are found, join them with '  or  '

    # log_it "add_rslt($1)"
    if [ -z "$ckb_rslt" ]; then
        ckb_rslt="$1"
    else
        ckb_rslt="$ckb_rslt  or  $1"
    fi
}

check_key_binds() {
    # Check if command is bound to a tmux shortcut.
    # If so list the shortcut(-s), otherwise display the command

    ckb_cmd="$1"
    ckb_output_var="$2"
    ckb_rslt=""
    # log_it "check_key_binds($ckb_cmd)"

    # Strip $TMUX_BIN from beginning if present
    ckb_no_tmux_bin=${ckb_cmd#"$TMUX_BIN "}

    extract_key_bind prefix "$ckb_no_tmux_bin" ckb_prefix_raw
    ckb_prefix_bind=""
    for key in $ckb_prefix_raw; do
        filter_bind_escapes_single "$key" ckb_escaped
        ckb_prefix_bind="${ckb_prefix_bind}${ckb_prefix_bind:+ }$ckb_escaped"
    done
    # log_it "><> ckb_prefix_raw [$ckb_prefix_raw] - ckb_prefix_bind [$ckb_prefix_bind]"

    extract_key_bind root "$ckb_no_tmux_bin" ckb_root_raw
    ckb_root_bind=""
    for key in $ckb_root_raw; do
        filter_bind_escapes_single "$key" ckb_escaped
        ckb_root_bind="${ckb_root_bind}${ckb_root_bind:+ }$ckb_escaped"
    done

    set -f # disable globbing - needed in case a bind is *
    [ -n "$ckb_root_bind" ] && {
        # shellcheck disable=SC2086 # intentional in this case
        set -- $ckb_root_bind
        for _l; do
            add_result "(NO-Prefix) $_l"
        done
    }
    [ -n "$ckb_prefix_bind" ] && {
        # shellcheck disable=SC2086 # intentional in this case
        set -- $ckb_prefix_bind
        for _l; do
            add_result "<prefix> $_l"
        done
    }
    set +f # re-enable globbing0

    # [ -z "$ckb_rslt" ] && ckb_rslt="$ckb_cmd" # if no binds were found display command

    if [ -n "$ckb_output_var" ]; then
        eval "$ckb_output_var=\"\$ckb_rslt\""
    else
        echo "$ckb_rslt"
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
    profiling_update_time_stamps
    _s1="${1%" $menu_reload"}"             # skip menu_reload suffix if found
    _s2="${_s1%" $reload_in_runshell"}"    # skip reload_in_runshell suffix if found
    _s3="${_s2%"; $0"}"                    # Remove trailing reload of menu
    _s4="$(echo "$_s3" | sed 's/\\&.*//')" # skip hint overlays, ie part after \&
    # reduce excessive white space
    sc_cmd=$(printf '%s\n' "$_s4" | awk '{$1=$1; print}')

    [ -z "$sc_cmd" ] && error_msg "show_cmd() - no command could be extracted"
    log_it "show_cmd($sc_cmd) $TMUX_MENUS_SHOW_CMDS"
    
    [ "$TMUX_MENUS_SHOW_CMDS" = "2" ] && {
        check_key_binds "$sc_cmd" sc_cmd
        log_it " binds [$sc_cmd]"
    }
    
    #  Replaces initial tmux-cmd with (TMUX) for clarity and to avoid risking
    #  starting with a long path
    # sc_cmd="$(echo "$sc_cmd" | sed "s#^$TMUX_BIN #(TMUX)  #")"

    #  Line break cmd if needed, to fit inside the menu width
    #  then calls mnu_text_line() for each line of the command to be displayed.
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
        mnu_text_line "-#[nodim]  $chunk"

        sc_remainder=${sc_remainder#"$chunk"}
        sc_remainder=${sc_remainder#" "}
    done
    profiling_display "show_cmd($sc_cmd) - done"
    # refresh it for each cmd processed in case the display timeout is shortish
    tmux_error_handler display-message "Preparing Display Commands ..."
}
