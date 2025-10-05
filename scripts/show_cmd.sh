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

#---------------------------------------------------------------
#
#  Find key binds matching command
#
#---------------------------------------------------------------

# Helper: invert quotes in a string
sc_invert_quotes() {
    # log_it "sc_invert_quotes()"
    printf %s "$1" | sed "s/'/@#@SQUOTE@#@/g; s/\"/'/g; s/@#@SQUOTE@#@/\"/g"
}

# Helper: run awk to extract matching key
sc_extract_key_bind_run_awk() {
    # log_it "sc_extract_key_bind_run_awk()"
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

add_result() {
    #
    #  Modifies:
    #   sc_ckb_rslt
    #
    # If multiple results are found, join them with '  or  '

    # log_it "add_result($1)"
    if [ -z "$sc_ckb_rslt" ]; then
        sc_ckb_rslt="$1"
    else
        sc_ckb_rslt="$sc_ckb_rslt  or  $1"
    fi
}

sc_filter_bind_escapes_single() {
    # when needed, changes bind sequence so that it is correctly displayed in
    # the menu
    #
    # Defines:
    #   sc_ckb_escaped
    #

    # Special notations
    # \" \# \$ \% \' \; \\ ` \{ \} \~
    # 'M-"' "M-#" "M-$" "M-%" "M-'" "M-;" M-\\ M-` "M-{" "M-}"
    #
    # multi mod order: C-S C-M M-S C-M-S

    # 2 is first char " or '

    sc_fbes_key=$1
    all_but_last_char=${sc_fbes_key%?}

    log_it "sc_filter_bind_escapes_single($sc_fbes_key)"

    # sc_ckb_escaped="$sc_fbes_key"
    # return
    # # 1 is first char \ ?
    # first_char=${sc_fbes_key%"${sc_fbes_key#?}"}
    case "$sc_fbes_key" in
    '\"' | "\\\\" | "\\\$" )
        sc_ckb_escaped="\\\\$sc_fbes_key"
        log_it "  special case - needs \ prefix - [$sc_ckb_escaped]"
        ;;
    *"\\")
        sc_ckb_escaped="$sc_fbes_key\\\\"
        log_it "  special case - ends in \ needs duplication [$sc_ckb_escaped]"
        ;;
    '"'*'"')
        sc_fbes_key=${sc_fbes_key#?}   # remove first char
        sc_fbes_key=${sc_fbes_key%?}   # remove last char
        sc_ckb_escaped='\"'"$sc_fbes_key"'\"'
        log_it "  special case - prefix dquotes [$sc_ckb_escaped]"
        ;;
    *'"'"'")
        all_but_last_two=${all_but_last_char%?}
        sc_ckb_escaped="$all_but_last_two"'\"'"'"
        log_it "  special case - ending dquote needs prefix [$sc_ckb_escaped]"
        unset  all_but_last_two
        ;;
    *'`')
        # backtick should be displayed without backslash, but they are needed
        # for this script
        sc_ckb_escaped="$all_but_last_char\\\`"
        log_it "  special case - ending in backtick [$sc_ckb_escaped]"
        ;;
    *) sc_ckb_escaped="$sc_fbes_key" ;;
    esac

    unset sc_fbes_key all_but_last_char
}


# Main: extract key bind
sc_extract_key_bind() {
    #
    # Defines:
    #   sc_ekb
    #
    sc_ekb_key_type="$1"
    sc_ekb_cmd="$2"

    # log_it "sc_extract_key_bind($sc_ekb_key_type, $sc_ekb_cmd)"

    [ -z "$sc_ekb_key_type" ] && {
        error_msg "sc_extract_key_bind() - missing param 1"
        return 1
    }
    [ -z "$sc_ekb_cmd" ] && {
        error_msg "sc_extract_key_bind($sc_ekb_key_type) - missing param 2"
        return 1
    }

    sc_ekb_keys=$(sc_extract_key_bind_run_awk "$sc_ekb_key_type" "$sc_ekb_cmd")
    [ ! -f "$f_cached_tmux_key_binds" ] && {
        error_msg "sc_extract_key_bind() not found: $f_cached_tmux_key_binds"
        return 1
    }

    if [ -z "$sc_ekb_keys" ]; then
        # nothing found, try inverting the quotes
        ekb_cmd_inverted=$(sc_invert_quotes "$sc_ekb_cmd")
        sc_ekb_keys=$(sc_extract_key_bind_run_awk "$sc_ekb_key_type" "$ekb_cmd_inverted")
    fi

    sc_ekb="$sc_ekb_keys"

    unset sc_ekb_key_type sc_ekb_cmd sc_ekb_keys
}

sc_check_key_binds() {
    #
    # Defines
    #   sc_processed
    #
    # Check if command is bound to a tmux shortcut, only prefix and root binds
    # are checked.
    # If found, list the shortcut(-s), otherwise display the command

    sc_ckb_cmd="$1"
    sc_ckb_rslt=""
    # log_it "sc_check_key_binds($sc_ckb_cmd)"

    sc_extract_key_bind prefix "$sc_ckb_cmd"
    # sc_ckb_prefix_bind=""
    # SC2154: sc_ekb assigned dynamically by sc_extract_key_bind using eval
    # shellcheck disable=SC2154
    for _key in $sc_ekb; do
        sc_filter_bind_escapes_single "$_key"
        sc_ckb_prefix_bind="${sc_ckb_prefix_bind}${sc_ckb_prefix_bind:+ }$sc_ckb_escaped"
    done

    sc_extract_key_bind root "$sc_ckb_cmd"
    # sc_ckb_root_bind=""
    # SC2154: sc_ckb_root_raw assigned dynamically by sc_extract_key_bind using eval
    # shell check disable=SC2154
    for _key in $sc_ekb; do
        sc_filter_bind_escapes_single "$_key"
        sc_ckb_root_bind="${sc_ckb_root_bind}${sc_ckb_root_bind:+ }$sc_ckb_escaped"
    done

    set -f # disable globbing - needed in case a bind is *
    [ -n "$sc_ckb_prefix_bind" ] && {
        # shellcheck disable=SC2086 # intentional not using quotes in this case
        set -- $sc_ckb_prefix_bind
        for _l; do
            add_result "<prefix> $_l"
        done
    }
    [ -n "$sc_ckb_root_bind" ] && {
        # shellcheck disable=SC2086 # intentionally not using quotes in this case
        set -- $sc_ckb_root_bind
        for _l; do
            add_result "$_l" # "[NO-Prefix] $_l"
        done
    }
    set +f # re-enable globbing0

    sc_processed="$sc_ckb_rslt"

    unset sc_ckb_cmd sc_ckb_rslt sc_ckb_prefix_bind sc_ckb_root_bind
    unset sc_ckb_escaped _key  _l
}

#---------------------------------------------------------------
#
#  Cleanup commands and results
#
#---------------------------------------------------------------

sc_filter_ws() {
    #
    # Defines
    #   sc_cmd - filtered input
    #

    #  Reduces excessive white space
    sc_fw_in="$1"

    # log_it "sc_filter_ws($sc_fw_in)"

    # Remove leading spaces (spaces only)
    sc_fw_cmd=${sc_fw_in#"${sc_fw_in%%[! ]*}"}
    # Remove trailing spaces (spaces only)
    sc_fw_cmd=${sc_fw_cmd%"${sc_fw_cmd##*[! ]}"}

    # Collapse inner whitespace to single spaces
    # shellcheck disable=SC2086 # intentional word splitting
    set -- $sc_fw_cmd
    sc_fw_cmd=$*

    sc_cmd="$sc_fw_cmd"

    unset sc_fw_in sc_fw_cmd
}

sc_clean_up_cmd() {
    # Does not remove TMUX_BIN prefix, needed for Display Commands
    #
    # Defines
    #   sc_cmd - via sc_filter_ws()
    #
    # log_it "sc_clean_up_cmd($1)"
    # if found purges $runshell_reload_mnu, $mnu_reload_direct & self reload

    _s1="${1%" $runshell_reload_mnu"}" # skip runshell_reload_mnu suffix if found
    _s2="${_s1%" $mnu_reload_direct"}" # skip mnu_reload_direct suffix if found
    _s3="${_s2%"; $0"}"                # Remove trailing reload of menu

    _s4=${_s3%%\\&*} # skip hint overlays, ie part after \&

    sc_filter_ws "$_s4"
}

sc_clean_up_result() {
    #
    # Expects
    #   sc_cmd - input
    # Defines
    #   sc_processed - processed output
    #
    sc_cur_input="$1"
    # sc_cur_output_var="$2"

    # log_it "sc_clean_up_result($sc_cur_input)"
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

    sc_processed="$sc_cur_rslt"

    unset sc_cur_input sc_cur_s1 sc_cur_s2 sc_cur_rslt
}

sc_display_cmd() {
    # Line break cmd if needed, to fit inside the menu width
    # then calls mnu_text_line() for each line of the command to be displayed.
    sc_dc_remainder="$1"

    # log_it "sc_display_cmd($sc_dc_remainder)"

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

    unset sc_dc_remainder
}

#===============================================================
#
#   Main  Entry point
#
#===============================================================

sc_show_cmd() {
    #
    # First filter out runshell_reload_mnu components if present
    # then try to match command to a prefix key-bind. If a match is foond
    # display the prefix sequence matching the cmd, otherwise display the command uses
    #
    #  Feeding the menu creation via calls to mnu_text_line()
    #

    sc_clean_up_cmd "$1" # defines sc_cmd

    [ -z "$sc_cmd" ] && error_msg "sc_show_cmd($1) - no command could be extracted"
    # log_it
    # log_it "sc_show_cmd($sc_cmd) - $_lbl"

    # shellcheck disable=SC2154 # show_cmds_state defined in display_commands_toggle()
    case "$show_cmds_state" in
    1)  # Display Commands
        sc_clean_up_result "$sc_cmd" sc_processed
        ;;
    2)  # Display key binds

        # Strip $TMUX_BIN from beginning if present
        cmd_no_tmux_bin=${sc_cmd#"$TMUX_BIN "}
        sc_check_key_binds "$cmd_no_tmux_bin"
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
