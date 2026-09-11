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
    # Invert single and double quotes in a string
    printf %s "$1" | sed "s/'/@#@SQUOTE@#@/g; s/\"/'/g; s/@#@SQUOTE@#@/\"/g"
}

# Helper: run awk to extract matching key
sc_extract_key_bind_run_awk() {
    # Find keybinding for target type and command using awk
    awk -v target="$1" -v cmd="$2" '
    {
        _sc_ekbra_found = 0
        _sc_ekbra_key_field = 0
        for (_sc_ekbra_i = 1; _sc_ekbra_i <= NF; _sc_ekbra_i++) {
            if ($_sc_ekbra_i == "-T" && (_sc_ekbra_i+1) <= NF && $(_sc_ekbra_i+1) == target) {
                _sc_ekbra_found = 1
                _sc_ekbra_key_field = _sc_ekbra_i + 2
            }
        }

        if (_sc_ekbra_found) {
            _sc_ekbra_cmd_start = _sc_ekbra_key_field + 1
            _sc_ekbra_actual_cmd = ""
            for (_sc_ekbra_j = _sc_ekbra_cmd_start; _sc_ekbra_j <= NF; _sc_ekbra_j++) {
                _sc_ekbra_actual_cmd = _sc_ekbra_actual_cmd (_sc_ekbra_j == _sc_ekbra_cmd_start ? "" : " ") $_sc_ekbra_j
            }

            if (_sc_ekbra_actual_cmd == cmd) {
                _sc_ekbra_key = $(_sc_ekbra_key_field)
                if (_sc_ekbra_key == "*") {
                    print "\\" _sc_ekbra_key
                } else {
                    print _sc_ekbra_key
                }
            }
        }
    }
    ' "$f_cached_tmux_key_binds"
}

add_result() {
    # Append result to sc_ckb_rslt, joining multiple results with ' or '
    if [ -z "$sc_ckb_rslt" ]; then
        sc_ckb_rslt="$1"
    else
        sc_ckb_rslt="$sc_ckb_rslt  or  $1"
    fi
}

sc_filter_bind_escapes_single() {
    # Escape special characters in bind sequences for display
    # Defines: sc_ckb_escaped
    # log_it "sc_filter_bind_escapes_single($1)"

    case "$1" in
        '\"' | "\\\\" | "\\\$")
            sc_ckb_escaped="\\\\$1"
            ;;
        *"\\")
            sc_ckb_escaped="$1\\\\"
            ;;
        '"'*'"')
            sc_ckb_escaped='\"'"${1#?}"'\"'
            sc_ckb_escaped="${sc_ckb_escaped%\"}"
            ;;
        *'"'"'")
            sc_ckb_escaped="${1%?}"'\"'"'"
            ;;
        *'`')
            sc_ckb_escaped="${1%?}\\\`"
            ;;
        *)
            sc_ckb_escaped="$1"
            ;;
    esac
}

sc_extract_key_bind() {
    # Extract keybindings of a given type for a command
    # Defines: sc_ekb
    _sc_ekb_type="$1"
    _sc_ekb_cmd="$2"

    [ -z "$_sc_ekb_type" ] && {
        error_msg "sc_extract_key_bind() - missing param 1"
        return 1
    }
    [ -z "$_sc_ekb_cmd" ] && {
        error_msg "sc_extract_key_bind() - missing param 2"
        return 1
    }

    [ ! -f "$f_cached_tmux_key_binds" ] && {
        error_msg "sc_extract_key_bind() not found: $f_cached_tmux_key_binds"
        return 1
    }

    sc_ekb=$(sc_extract_key_bind_run_awk "$_sc_ekb_type" "$_sc_ekb_cmd")

    # If no match found, try with inverted quotes
    if [ -z "$sc_ekb" ]; then
        sc_ekb=$(sc_extract_key_bind_run_awk "$_sc_ekb_type" "$(sc_invert_quotes "$_sc_ekb_cmd")")
    fi
}

sc_append_bind_result() {
    # Extract binds of a given type, format them, and add to results
    # Params: bind_type (prefix/root), command, prefix_string_for_display
    _sc_abr_type="$1"
    _sc_abr_cmd="$2"
    _sc_abr_prefix="$3"

    sc_extract_key_bind "$_sc_abr_type" "$_sc_abr_cmd"

    for _sc_abr_key in $sc_ekb; do
        sc_filter_bind_escapes_single "$_sc_abr_key"
        _sc_abr_result="${_sc_abr_prefix}${_sc_abr_prefix:+ }$sc_ckb_escaped"
        add_result "$_sc_abr_result"
    done
}

sc_check_key_binds() {
    # Check if command is bound to a tmux shortcut (prefix and root binds only)
    # Defines: sc_processed

    sc_ckb_rslt=""

    sc_append_bind_result prefix "$1" "<prefix>"
    sc_append_bind_result root "$1" ""

    sc_processed="$sc_ckb_rslt"
}

#---------------------------------------------------------------
#
#  Cleanup commands and results
#
#---------------------------------------------------------------

sc_filter_ws() {
    # Reduces excessive whitespace: trim and collapse inner spaces
    # Defines: sc_cmd
    _sc_fw_input="$1"

    # Remove leading/trailing spaces and collapse inner whitespace
    # shellcheck disable=SC2086 # intentionally unquoted string
    set -- $_sc_fw_input
    sc_cmd="$*"
}

sc_clean_up_cmd() {
    # Remove menu reload and hint overlay suffixes
    # Defines: sc_cmd (via sc_filter_ws)
    _sc_cuc_cmd="$1"

    # Remove reload suffixes and hint overlays
    _sc_cuc_cmd="${_sc_cuc_cmd%" $runshell_reload_mnu"}"
    _sc_cuc_cmd="${_sc_cuc_cmd%" $mnu_reload_direct"}"
    _sc_cuc_cmd="${_sc_cuc_cmd%"; $0"}"
    _sc_cuc_cmd="${_sc_cuc_cmd%%\\&*}"

    sc_filter_ws "$_sc_cuc_cmd"
}

sc_clean_up_result() {
    # Format command for display: replace paths with readable tags
    # Defines: sc_processed
    _sc_cur_result="$1"

    # Escape # to ## to prevent tmux variable expansion
    _sc_cur_result=$(printf '%s\n' "$_sc_cur_result" | sed 's/#/##/g')

    # Replace tmux path with tag
    case $_sc_cur_result in
        "$TMUX_BIN "*) _sc_cur_result='[TMUX] '"${_sc_cur_result#"$TMUX_BIN "}" ;;
        *) ;;
    esac

    # Replace plugin path with tag
    case $_sc_cur_result in
        "$D_TM_BASE_PATH/"*) _sc_cur_result='[tmux-menus] '"${_sc_cur_result#"$D_TM_BASE_PATH/"}" ;;
        *) ;;
    esac

    sc_processed="$_sc_cur_result"
}

sc_display_cmd() {
    # Line break cmd if needed, to fit inside the menu width
    # then calls mnu_text_line() for each line of the command to be displayed.
    _sc_dc_remainder="$1"

    while [ -n "$_sc_dc_remainder" ]; do
        _sc_dc_chunk=$(printf '%s\n' "$_sc_dc_remainder" | awk -v max="$cfg_display_cmds_cols" '
        {
            if (length($0) <= max) {
                print $0
            } else {
                for (_sc_dc_i = max; _sc_dc_i > 0; _sc_dc_i--) {
                    if (substr($0, _sc_dc_i, 1) ~ /[[:space:]]/) {
                        print substr($0, 1, _sc_dc_i)
                        exit
                    }
                }
                # No space found, just cut at max
                print substr($0, 1, max)
            }
        }')
        mnu_text_line "  $_sc_dc_chunk"

        _sc_dc_remainder=${_sc_dc_remainder#"$_sc_dc_chunk"}
        _sc_dc_remainder=${_sc_dc_remainder#" "}
    done
}

#===============================================================
#
#   Main  Entry point
#
#===============================================================

sc_show_cmd() {
    # Process command for Display Commands view: clean up, find keybinds or format
    # Adds display lines via mnu_text_line()

    sc_clean_up_cmd "$1"
    [ -z "$sc_cmd" ] && error_msg "sc_show_cmd($1) - no command could be extracted"

    case "$show_cmds_state" in
        1)
            # Display mode: show cleaned command
            sc_clean_up_result "$sc_cmd"
            ;;
        2)
            # Keybind mode: check if command is bound to a shortcut
            sc_check_key_binds "${sc_cmd#"$TMUX_BIN "}"
            ;;
        *)
            ;;
    esac

    sc_display_cmd "$sc_processed"
    set_display_command_labels
    tmux_error_handler display-message "Preparing $_lbl ..."
}

#===============================================================
#
#   Main
#
#===============================================================

if false; then
    # Shellcheck analyzes this code path but it never executes at runtime
    . tools/variables_meta.sh
fi
