#!/bin/sh
# This is sourced. Fake bang-path to help editors and linters
#
#   Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Add extra line in menu displaying what command an action would use
#  if the command is available using a prefix bind, display this instead of the cmd
#

# Helper: run awk to extract matching key
sc_extract_key_bind_run_awk() {
    # shellcheck disable=SC2154 # f_cached_tmux_key_binds defined in helpers_minimal.sh
    awk -v target="$1" -v cmd="$2" '
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
}

# Helper: invert quotes in a string
sc_invert_quotes() {
    printf %s "$1" | sed "s/'/@#@SQUOTE@#@/g; s/\"/'/g; s/@#@SQUOTE@#@/\"/g"
}

# Main: extract key bind
sc_extract_key_bind() {
    sc_ekb_key_type="$1"
    sc_ekb_cmd="$2"
    sc_ekb_output_var="$3"

    [ -z "$sc_ekb_cmd" ] && {
        error_msg "sc_extract_key_bind($sc_ekb_key_type, $sc_ekb_cmd) - command empty"
        return 1
    }

    [ ! -f "$f_cached_tmux_key_binds" ] && {
        error_msg "sc_extract_key_bind() not found: $f_cached_tmux_key_binds"
        return 1
    }

    # log_it "sc_extract_key_bind($sc_ekb_key_type, $sc_ekb_cmd, $sc_ekb_output_var)"
    sc_ekb_keys=$(sc_extract_key_bind_run_awk "$sc_ekb_key_type" "$sc_ekb_cmd")

    if [ -z "$sc_ekb_keys" ]; then
        ekb_cmd_inverted=$(sc_invert_quotes "$sc_ekb_cmd")
        sc_ekb_keys=$(sc_extract_key_bind_run_awk "$sc_ekb_key_type" "$ekb_cmd_inverted")
    fi

    if [ -n "$sc_ekb_output_var" ]; then
        eval "$sc_ekb_output_var=\"\$sc_ekb_keys\""
    else
        echo "$sc_ekb_keys"
    fi
}

sc_filter_bind_escapes_single() {
    # some bind chars are prefixed with \
    # this func removed them, except for a few special cases that must be escaped
    # in order to be displayed with display-menu.
    # For those chars, display-menu will unescape them.
    sc_fbes_key=$1
    sc_fbes_output_var="$2"
    sc_fbes_last_char=$(printf '%s\n' "$sc_fbes_key" | awk '{print substr($0,length,1)}')

    # log_it "sc_filter_bind_escapes_single($sc_fbes_key, $sc_fbes_output_var) [$sc_fbes_last_char]"
    [ -z "$sc_fbes_output_var" ] && {
        error_msg "sc_filter_bind_escapes_single() - missing param 2"
    }

    case "$sc_fbes_last_char" in
    ';' | '"')
        # printf '%s\n' "$sc_fbes_key"
        eval "$sc_fbes_output_var=\"$sc_fbes_key\""
        ;;
    *)
        clean_key=$(printf '%s\n' "$sc_fbes_key" | tr -d "\\")
        # printf '%s\n' "$clean_key"
        eval "$sc_fbes_output_var=\"$clean_key\""
        ;;
    esac
}

add_result() {
    #
    #  Manipulates sc_ckb_rslt
    #
    # If multiple results are found, join them with '  or  '

    # log_it "add_rslt($1)"
    if [ -z "$sc_ckb_rslt" ]; then
        sc_ckb_rslt="$1"
    else
        sc_ckb_rslt="$sc_ckb_rslt  or  $1"
    fi
}

sc_check_key_binds() {
    # Check if command is bound to a tmux shortcut.
    # If so list the shortcut(-s), otherwise display the command

    sc_ckb_cmd="$1"
    sc_ckb_output_var="$2"
    sc_ckb_rslt=""
    # log_it "sc_check_key_binds($sc_ckb_cmd)"

    sc_extract_key_bind prefix "$sc_ckb_cmd" sc_ckb_prefix_raw
    sc_ckb_prefix_bind=""
    # SC2154: sc_ckb_prefix_raw assigned dynamically by sc_extract_key_bind using eval
    # shellcheck disable=SC2154
    for _key in $sc_ckb_prefix_raw; do
        sc_filter_bind_escapes_single "$_key" sc_ckb_escaped
        sc_ckb_prefix_bind="${sc_ckb_prefix_bind}${sc_ckb_prefix_bind:+ }$sc_ckb_escaped"
    done

    sc_extract_key_bind root "$sc_ckb_cmd" sc_ckb_root_raw
    sc_ckb_root_bind=""
    # SC2154: sc_ckb_root_raw assigned dynamically by sc_extract_key_bind using eval
    # shellcheck disable=SC2154
    for _key in $sc_ckb_root_raw; do
        sc_filter_bind_escapes_single "$_key" sc_ckb_escaped
        sc_ckb_root_bind="${sc_ckb_root_bind}${sc_ckb_root_bind:+ }$sc_ckb_escaped"
    done

    set -f # disable globbing - needed in case a bind is *
    [ -n "$sc_ckb_root_bind" ] && {
        # shellcheck disable=SC2086 # intentionally not using quotes in this case
        set -- $sc_ckb_root_bind
        for _l; do
            add_result "$_l" # "[NO-Prefix] $_l"
        done
    }
    [ -n "$sc_ckb_prefix_bind" ] && {
        # shellcheck disable=SC2086 # intentional not using quotes in this case
        set -- $sc_ckb_prefix_bind
        for _l; do
            add_result "<prefix> $_l"
        done
    }
    set +f # re-enable globbing0

    if [ -n "$sc_ckb_output_var" ]; then
        eval "$sc_ckb_output_var=\"\$sc_ckb_rslt\""
    else
        echo "$sc_ckb_rslt"
    fi
}

sc_filter_ws() {
    #
    # Reduce excessive white space
    #
    sc_fw_in="$1"
    sc_fw_output_var="$2"

    # # old method
    # sc_fw_cmd=$(printf '%s\n' "$sc_fw_in" | awk '{$1=$1; print}')

    # Remove leading spaces (spaces only)
    sc_fw_cmd=${sc_fw_in#"${sc_fw_in%%[! ]*}"}
    # Remove trailing spaces (spaces only)
    sc_fw_cmd=${sc_fw_cmd%"${sc_fw_cmd##*[! ]}"}

    # Collapse inner whitespace to single spaces
    # shellcheck disable=SC2086 # intentional word splitting
    set -- $sc_fw_cmd
    sc_fw_cmd=$*

    if [ -n "$sc_fw_output_var" ]; then
        eval "$sc_fw_output_var=\"\$sc_fw_cmd\""
    else
        echo "$sc_fw_cmd"
    fi
}

sc_clean_up_cmd() {
    # Defines
    #   sc_cmd - filtered input

    _s1="${1%" $runshell_reload_mnu"}" # skip runshell_reload_mnu suffix if found
    _s2="${_s1%" $mnu_reload_direct"}" # skip mnu_reload_direct suffix if found
    _s3="${_s2%"; $0"}"                # Remove trailing reload of menu

    # _s4="$(echo "$_s3" | sed 's/\\&.*//')"
    _s4=${_s3%%\\&*} # skip hint overlays, ie part after \&

    sc_filter_ws "$_s4" sc_cmd
}

sc_clean_up_result() {
    # Expects:
    #   sc_cmd - input
    # Defines
    #   sc_processed - processed output
    #
    sc_cur_input="$1"
    sc_cur_output_var="$2"

    #
    # prevent tmux variables from being expanded by dobeling # into ##
    #
    sc_cur_s1=$(printf '%s\n' "$sc_cur_input" | sed 's/#/##/g')

    #
    # Replaces initial tmux-cmd with [TMUX] for clarity and to avoid risking
    # starting with a long path
    #

    # _s2="$(echo "$sc_cur_s1" | sed "s#^$TMUX_BIN #[TMUX] #")"

    # shellcheck disable=SC2154 # TMUX_BIN defined in helpers_minimal.sh
    case $sc_cur_s1 in
    "$TMUX_BIN "*) sc_cur_s2='[TMUX] '"${sc_cur_s1#"$TMUX_BIN "}" ;;
    *) sc_cur_s2=$sc_cur_s1 ;;
    esac

    #
    # Replaces script path starting with plugin location with [tmux-menus]
    # to avoid long absolute paths that are redundant
    #

    # shellcheck disable=SC2154 # TMUX_BIN defined in $0 calling script
    case $sc_cur_s2 in
    "$D_TM_BASE_PATH/"*) sc_cur_rslt='[tmux-menus] '"${sc_cur_s2#"$D_TM_BASE_PATH/"}" ;;
    *) sc_cur_rslt=$sc_cur_s2 ;;
    esac

    if [ -n "$sc_cur_output_var" ]; then
        eval "$sc_cur_output_var=\"\$sc_cur_rslt\""
    else
        echo "$sc_cur_rslt"
    fi

}

sc_display_cmd() {
    # Line break cmd if needed, to fit inside the menu width
    # then calls mnu_text_line() for each line of the command to be displayed.
    sc_dc_remainder="$1"

    while [ -n "$sc_dc_remainder" ]; do
        # shellcheck disable=SC2154 # cfg_display_cmds_cols defined in cache/plugin_params
        sc_dc_chunk=$(printf '%s\n' "$sc_dc_remainder" | awk -v max="$cfg_display_cmds_cols" '
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
        mnu_text_line "-#[nodim]  $sc_dc_chunk"

        sc_dc_remainder=${sc_dc_remainder#"$sc_dc_chunk"}
        sc_dc_remainder=${sc_dc_remainder#" "}
    done
}

sc_show_cmd() {
    #
    # First filter out runshell_reload_mnu components if present
    # then try to match command to a prefix key-bind. If a match is foond
    # display the prefix sequence matching the cmd, otherwise display the command uses
    #
    #  Feeding the menu creation via calls to mnu_text_line()
    #

    sc_clean_up_cmd "$1"

    [ -z "$sc_cmd" ] && error_msg "sc_show_cmd() - no command could be extracted"
    # log_it
    # log_it "sc_show_cmd($sc_cmd)"

    # shellcheck disable=SC2154 # show_cmds_state defined in display_commands_toggle()
    case "$show_cmds_state" in
    1)
        sc_clean_up_result "$sc_cmd" sc_processed
        ;;
    2)
        # Strip $TMUX_BIN from beginning if present
        cmd_no_tmux_bin=${sc_cmd#"$TMUX_BIN "}

        sc_check_key_binds "$cmd_no_tmux_bin" sc_processed
        ;;
    *) ;;
    esac

    # SC2154: sc_processed assigned dynamically by above using eval
    # shellcheck disable=SC2154
    sc_display_cmd "$sc_processed"

    # refresh it for each cmd processed in case the display timeout is shortish
    set_display_command_labels
    # shellcheck disable=SC2154 # _lbl definef in set_display_command_labels()
    tmux_error_handler display-message "Preparing $_lbl ..."
}
