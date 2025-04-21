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
            for (i = 1; i <= NF; i++) {
                if ($i == "-T" && (i+1) <= NF && $(i+1) == target) {
                    found_target = 1
                    key_field = i + 2
                }
            }

            if (found_target && $0 ~ cmd "$") {
                print $(key_field)
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

filter_bind_escapes() {
    # log_it "filter_bind_escapes($$key)"
    while IFS= read -r key; do
        last_char=$(expr "$key" : '.*\(.\)$')
        case "$last_char" in
        ';' | '"')
            echo "$key"
            ;;
        *)
            echo "$key" | sed 's/\\//g'
            ;;
        esac
    done
}

add_result() {
    # log_it "add_rslt($1)"

    if [ -z "$rslt" ]; then
        rslt="$1"
    else
        rslt="$rslt  or  $1"
    fi
}

check_key_binds() {
    ckb_cmd="$1"
    rslt=""
    # log_it "check_key_binds($ckb_cmd)"

    # Strip $TMUX_BIN from beginning if present
    ckb_no_tmux_bin=${ckb_cmd#"$TMUX_BIN "}

    extract_key_bind prefix "$ckb_no_tmux_bin" ckb_prefix_raw
    profiling_display "extract_key_bind prefix"
    ckb_prefix_bind=$(printf "%s\n" "$ckb_prefix_raw" | filter_bind_escapes)
    profiling_display "filter_bind_escapes prefix"

    extract_key_bind root "$ckb_no_tmux_bin" ckb_root_raw
    profiling_display "extract_key_bind root"
    ckb_root_bind=$(printf "%s\n" "$ckb_root_raw" | filter_bind_escapes)
    profiling_display "filter_bind_escapes root"

    [ -n "$ckb_root_bind" ] && {
        # shellcheck disable=SC2086 # intentional in this case
        set -- $ckb_root_bind
        for line; do
            add_result "(NO-Prefix) $line"
        done
    }

    [ -n "$ckb_prefix_bind" ] && {
        # shellcheck disable=SC2086 # intentional in this case
        set -- $ckb_prefix_bind
        for line; do
            add_result "<prefix> $line"
        done
    }

    [ -z "$rslt" ] && rslt="$ckb_cmd" # if no binds were found display command
    echo "$rslt"
}

show_cmd() {
    #
    # First filter out menu_reload components if present
    # then try to match command to a prefix key-bind. If a match is foond
    # display the prefix sequence matching the cmd, otherwise display the command uses
    #
    #  Feeding the menu creation via calls to mnu_text_line()
    #
    log_it
    profiling_update_time_stamps
    _s1="${1%" $menu_reload"}"             # skip menu_reload suffix if found
    _s2="${_s1%" $reload_in_runshell"}"    # skip reload_in_runshell suffix if found
    _s3="${_s2%"; $0"}"                    # Remove trailing reload of menu
    _s4="$(echo "$_s3" | sed 's/\\&.*//')" # skip hint overlays, ie part after \&
    # reduce excessive white space
    sc_cmd=$(printf '%s\n' "$_s4" | awk '{$1=$1; print}')
    profiling_display "sc_cmd defined"
    # log_it "show_cmd($sc_cmd)"

    [ -z "$sc_cmd" ] && error_msg "show_cmd() - no command could be extracted"
    sc_cmd="$(check_key_binds "$sc_cmd")"
    profiling_display "check_key_binds done"

    #  Replaces initial tmux-cmd with (TMUX) for clarity and to avoid risking
    #  starting with a long path
    sc_cmd="$(echo "$sc_cmd" | sed "s#^$TMUX_BIN #(TMUX)  #")"
    profiling_display "TMUX prefix removed"

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
    profiling_display "result line split"

    # refresh it for each cmd processed in case the display timeout is shortish
    tmux_error_handler display-message "Preparing Display Commands ..."

    profiling_display "end show_cmd()"
}
