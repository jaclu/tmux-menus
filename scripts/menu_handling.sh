#!/bin/sh
# This script is sourced. Fake shebang to assist editors and linters.
#
#   Copyright (c) 2023–2026: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Parses menu definitions and generates tmux or whiptail menus.
#
#   Expected definitions for each menu:
#     D_TM_BASE_PATH     – Base directory of the tmux-menus plugin
#     menu_name          – Name of the menu
#     static_content()   – Defines static menu content; can be cached
#     dynamic_content()  – Defines dynamic content; regenerated each time
#
#   Optional variables:
#     menu_min_vers      – Minimum tmux version required
#     menu_height        – Number of rows required to display the menu
#     menu_width         – Number of columns required to display the menu
#     skip_oversized     – If set to 1, the menu will be silently skipped
#                          if it's too large to fit on the current display.
#                          Requires both menu_height and menu_width to be set.
#
# When debugging menu generation, ensure @menus_use_cache is disabled,
# or manually clear the relevant cache entry before each run.
# Otherwise, cached items won't be fully processed,
# unless you're debugging how the cache works.
#

#---------------------------------------------------------------
#
#   Common
#
#---------------------------------------------------------------

get_mtime() {
    _gm_fname="$1"
    # [ -f "$_gm_fname" ] || return 1

    # date -r should normally work and is faster than stat
    # then try GNU/Linux, BSD & Darwin fallback, finally return 0
    date -r "$_gm_fname" +%s 2>/dev/null \
        || stat -c %Y "$_gm_fname" 2>/dev/null \
        || stat -f %m "$_gm_fname" 2>/dev/null \
        || printf 0 # indicate failed mtime retrieval by setting a zero timestamp
}

debug_print() {
    case "$menu_debug" in
        "") ;; # not active
        1) print_stderr "$1" ;;
        2) log_it "$1" ;;
        *)
            error_msg "$menu_debug state invalid [$menu_debug] should be 1 or 2! p1[$1]"
            ;;
    esac
}

starting_with_dash() {
    #  In whiptail/dialog, an initial '-'' in a label causes the menu to
    #  fail, in tmux menus this is used to indicate dimmed (disabled)
    #  entries, for whiptail/dialog entries with such labels are just
    #  ignored

    case "$1" in
        -*) return 0 ;;
        *) return 1 ;;
    esac
}

is_function_defined() {
    command -v "$1" >/dev/null 2>&1
}

run_if_found() {
    # this checks if function is present and runs it
    # returning 0 if it was found (and thus executed)
    is_function_defined "$1" && {
        $1
        return 0
    }
    return 1
}

update_wt_actions() {
    # log_it "update_wt_actions()"
    if $cfg_use_cache; then
        mkdir -p "$d_wt_actions"
        echo "$wt_actions" >"$d_wt_actions/$menu_idx"
    else
        uncached_wt_actions="$uncached_wt_actions $wt_actions"
    fi
}

#---------------------------------------------------------------
#
#   Error handling
#
#---------------------------------------------------------------

show_params() {
    # This will log the exact arguments passed to the script
    for param in "$@"; do
        # Print each argument enclosed in quotes
        printf '%s ' "$param"
    done
    echo
}

verify_menu_runable() {
    # Check that menu starts with a menu handling cmd, if not most likely due to
    # menu idx 1 not generated, but could be other causes. eithe way this menu
    # will be displayable...
    # log_it "verify_menu_runable()"

    # extract first word
    _actual_first="${menu_items%% *}"

    if [ -n "$cfg_alt_menu_handler" ]; then
        _mnu_first="$cfg_alt_menu_handler"
    else
        _mnu_first="${TMUX_BIN%% *}"
    fi
    [ "$_actual_first" = "$_mnu_first" ]
}

mnu_parse_error() {
    log_it "mnu_parse_error()"
    failed_action="$1"
    shift

    s_remainders=$(show_params "$@")

    #region error_msg explaining parsing error
    _mpe_msg="$(
        cat <<EOF
Parsing error when processing menu.

Due to limits in what can be displayed in this error, all usages of single-quote
have been replaced by backticks, in the "Menu created so far" in order to give as
close a reppresentation as possible

-----   Menu created so far   -----
$menu_items
-----------------------------------


Failed to Parse this action: $failed_action


In the next section all quotes have been eliminated due to how parsing remaining
arguments is limited, hopefully it will at least give a hint on where parsing failed.

-----   Remainder of menu   -----
$s_remainders
---------------------------------

EOF
    )"
    #endregion
    error_msg "$_mpe_msg"
}

display_invalid_menu_error() {
    e_msg="$1"
    log_it "display_invalid_menu_error()"

    [ -n "$e_msg" ] && {
        #region e_msg = Error message
        e_msg="$(
            cat <<EOF
-----   Error message   -----
$e_msg
-----------------------------

EOF
        )"
        #endregion
    }
    if verify_menu_runable; then
        log_it "  - was runable"
    else
        log_it "  - NOT runable"
        #region e_first = first word in rendered menu wrong
        e_first="$(
            cat <<EOF


The processed menu should start with a menu handler.
In the current environment this was expected:

    $_mnu_first

This was found:

    $_actual_first

Was no part 1 created?

The menu handler and other menu definitions like title and styling
are prepended to the part created by:

    menu_generate_part 1 "\$@"
EOF
        )"
        #endregion
    fi

    _dime_cache_info=""
    if [ -n "$d_menu_cache" ]; then
        _dime_cache_info=$(printf '\nThe original cached snippets that generated the above, can be found
    here:\n  %s/\n\n' "$d_menu_cache")
    fi

    #region m_menu_code = Display the generated menu code
    m_menu_code="$(
        cat <<EOF

  Menu Exit code: $menu_exit_code

  Generated menu below

  -----   menu start   -----
  $menu_items
  -----    menu end    -----
  $_dime_cache_info
EOF
    )"
    #endregion

    error_msg "$e_msg\n$e_first\n$m_menu_code"
}

#---------------------------------------------------------------
#
#   Processing menu items
#
#---------------------------------------------------------------

mnu_prefix() {

    _title="$(echo "$cfg_format_title" | sed "s/#{@menu_name}/$menu_name/g")"
    menu_items="$TMUX_BIN display-menu -T $_title -x '$cfg_mnu_loc_x' -y '$cfg_mnu_loc_y'"

    tmux_vers_check 3.4 && {
        # Styling is supported
        [ -n "$cfg_border_type" ] && {
            menu_items="$menu_items -b $cfg_border_type"
        }
        [ -n "$cfg_simple_style_selected" ] && {
            menu_items="$menu_items -H $cfg_simple_style_selected"
        }
        [ -n "$cfg_simple_style" ] && menu_items="$menu_items -s $cfg_simple_style"
        [ -n "$cfg_simple_style_border" ] && {
            menu_items="$menu_items -S $cfg_simple_style_border"
        }
    }
}

mnu_open_menu() {
    label="$1"
    key="$2"
    menu="$3"

    # [ -n "$menu_debug" ] && debug_print "mnu_open_menu($label,$key,$menu)"

    menu_items="$menu_items \"$label\" $key \"run-shell '$menu'\""
}

mnu_external_cmd() {
    _mec_label="$1"
    key="$2"
    cmd="$(printf '%s\n' "$3" | sed 's/"/\\"/g')"

    #
    #  needs to be prefixed with run-shell, since this is triggered by
    #  tmux
    #
    menu_items="$menu_items \"$_mec_label\" $key 'run-shell \"$cmd\"'"
}

mnu_command() {
    _mc_label="$1"
    _mc_key="$2"

    cmd="$(printf '%s\n' "$3" | sed 's/"/\\"/g')"

    # [ -n "$menu_debug" ] && debug_print "mnu_command($_mc_label,$_mc_key,$cmd)"
    menu_items="$menu_items \"$_mc_label\" $_mc_key \"$cmd\""
}

mnu_text_line() {
    txt="$1"
    menu_items="$menu_items \"$txt\" '' ''"
}

mnu_spacer() {
    menu_items="$menu_items \"\""
}

alt_prefix() {
    case "$cfg_alt_menu_handler" in
        whiptail | dialog) ;;
        *) error_msg "Un-recognized cfg_alt_menu_handler: [$cfg_alt_menu_handler]" ;;
    esac
    menu_items="$cfg_alt_menu_handler --title \"$menu_name\"  --menu \"\" 0 0 0 "
}

alt_open_menu() {
    _aom_label="$1"
    key="$2"
    menu="$3"

    #
    #  labels starting with - indicates disabled feature in tmux notation,
    #  whiptail can not handle labels starting with -, so just skip
    #  those lines
    #
    starting_with_dash "$_aom_label" && return

    menu_items="$menu_items $key \"$_aom_label\""
    wt_actions="$wt_actions $key | $menu $external_action_separator"
}

alt_external_cmd() {
    _aec_label="$1"
    key="$2"
    cmd="$3"

    #
    #  labels starting with - indicates disabled feature in tmux notation,
    #  whiptail can not handle labels starting with -, so just skip
    #  those lines
    #
    starting_with_dash "$_aec_label" && return

    menu_items="$menu_items $key \"$_aec_label\""
    # This will run outside tmux, so should not have run-shell prefix
    wt_actions="$wt_actions $key | $cmd $external_action_separator"
}

alt_command() {
    # filtering out tmux #{...} & #[...] sequences
    _ac_label="$(echo "$1" | sed 's/#{[^}]*}//g' | sed 's/#\[[^}]*\]//g')"
    key="$2"
    cmd="$3"

    #
    #  labels starting with - indicates disabled feature in tmux notation,
    #  whiptail can not handle labels starting with -, so just skip
    #  those lines
    #
    starting_with_dash "$_ac_label" && return

    # filer out backslashes prefixing special chars
    key_action="$(echo "$key" | sed 's/\\//')"

    menu_items="$menu_items $key \"$_ac_label\""
    wt_actions="$wt_actions $key_action | tmux_error_handler_assign wt_output $cmd $external_action_separator"
}

alt_text_line() {
    #  - filtering out tmux #[...] sequences for styling
    txt="$(printf '%s\n' "$1" | sed 's/#\[[^]]*\]//g')"

    #  - removes initial dash (-) from string, whiptail can not handle labels
    #     starting with -, so remove it
    case "$txt" in
        -*) txt=" ${txt#-}" ;;
        *) ;; # do nothing default case
    esac

    menu_items="$menu_items '' \"$txt\""
}

alt_spacer() {
    menu_items="$menu_items '' ' '"
}

add_uncached_item() {
    # log_it "add_uncached_item()"
    #  Add one item to $uncached_menu
    _new_item="$menu_idx $menu_items"
    if [ -n "$uncached_menu" ]; then
        uncached_menu="$uncached_menu$uncached_item_splitter$_new_item"
    else
        uncached_menu="$_new_item"
    fi
}

verify_menu_key() {
    _key="$1"
    _item="$2"
    [ -z "$_key" ] && error_msg "Key was empty for: $_item in: $0"
}

menu_parse() {
    #
    #  Since the various menu entries have different numbers of params
    #  we first identify all the params used by the different options,
    #  only then can we continue if the _mp_min_vers does not match running tmux
    #
    # log_it "mennu_parse()"

    menu_items=""
    [ "$menu_idx" -eq 1 ] && {
        # set prefix for item 1
        if $cfg_use_whiptail; then
            alt_prefix
        else
            mnu_prefix
        fi
    }

    [ -n "$menu_debug" ] && debug_print ">> menu_parse($menu_idx)"
    while [ -n "$1" ]; do
        _mp_min_vers="$1"
        shift
        _mp_action="$1"
        shift

        [ -n "$menu_debug" ] && debug_print "-- parsing an item [$_mp_min_vers] [$_mp_action]"
        case "$_mp_action" in

            "C")
                #  direct tmux command - params: key label task
                _mp_key="$1"
                shift
                _mp_label="$1"
                shift
                _mp_cmd="$1"
                shift

                # first extract the variables, then  if it shouldn't be used move on
                ! tmux_vers_check "$_mp_min_vers" && continue

                verify_menu_key "$_mp_key" "tmux command: $_mp_cmd"

                [ -n "$menu_debug" ] && debug_print "key[$_mp_key] label[$_mp_label] command[$_mp_cmd]"

                if $cfg_use_whiptail; then
                    alt_command "$_mp_label" "$_mp_key" "$_mp_cmd"
                else
                    mnu_command "$_mp_label" "$_mp_key" "$_mp_cmd"
                    $b_do_show_cmds && sc_show_cmd "$TMUX_BIN $_mp_cmd"
                fi
                ;;

            E)
                #
                #  Run external command - params: _mp_key _mp_label _mp_cmd
                #
                #  If no initial / is found in the script param, it will be prefixed with
                #  $d_scripts
                #  This means that if you give full path to something in this
                #  param, all scriptd needs to have full path prepended.
                #  For example help menus, which takes the full path to the
                #  current script, in order to be able to go back.
                #  For the normal case a name pointing to a script in the same
                #  dir as the current, this will be prepended automatically.
                #
                _mp_key="$1"
                shift
                _mp_label="$1"
                shift
                _mp_cmd="$1"
                shift

                # first extract the variables, then  if it shouldn't be used move on
                ! tmux_vers_check "$_mp_min_vers" && continue

                verify_menu_key "$_mp_key" "external command: $_mp_cmd"

                [ -n "$menu_debug" ] && debug_print "key[$_mp_key] label[$_mp_label] command[$_mp_cmd]"

                if $cfg_use_whiptail; then
                    alt_external_cmd "$_mp_label" "$_mp_key" "$_mp_cmd"
                else
                    mnu_external_cmd "$_mp_label" "$_mp_key" "$_mp_cmd"
                    $b_do_show_cmds && [ "$_mp_key" != "!" ] && sc_show_cmd "$_mp_cmd"
                fi
                ;;

            "M")
                #  Open another menu
                _mp_key="$1"
                shift
                _mp_label="$1"
                shift
                menu="$1"
                shift

                # first extract the variables, then  if it shouldn't be used move on
                ! tmux_vers_check "$_mp_min_vers" && continue

                verify_menu_key "$_mp_key" "$menu"

                #
                #  If menu is not full PATH, assume it to be a tmux-menus
                #  item
                #
                case $menu in
                    */*) ;;
                    *) menu="$d_items/$menu" ;;
                esac

                [ -n "$menu_debug" ] && debug_print "key[$_mp_key] label[$_mp_label] menu[$menu]"

                if $cfg_use_whiptail; then
                    alt_open_menu "$_mp_label" "$_mp_key" "$menu"
                else
                    mnu_open_menu "$_mp_label" "$_mp_key" "$menu"
                fi
                ;;

            "T")
                #  text line - params: txt
                txt="$1"
                shift

                # first extract the variables, then  if it shouldn't be used move on
                ! tmux_vers_check "$_mp_min_vers" && continue

                [ -n "$menu_debug" ] && debug_print "text line [$txt]"
                if $cfg_use_whiptail; then
                    alt_text_line "$txt"
                else
                    mnu_text_line "$txt"
                fi
                ;;

            "S")
                #  Spacer line - params: none

                # first extract the variables, then  if it shouldn't be used move on
                ! tmux_vers_check "$_mp_min_vers" && continue

                [ -n "$menu_debug" ] && debug_print "Spacer line"

                # Whiptail/dialog does not have a concept of spacer lines
                if $cfg_use_whiptail; then
                    alt_spacer
                else
                    mnu_spacer
                fi
                ;;

            *) mnu_parse_error "$_mp_action" "$@" ;;
        esac
    done

    if $cfg_use_cache; then
        _mp_rel_path=$(relative_path "$f_cache_file")
        log_it_minimal "Caching: $_mp_rel_path"
        echo "$menu_items" >"$f_cache_file" || {
            error_msg "Failed to write to: $f_cache_file"
        }
    else
        add_uncached_item
    fi
    unset menu_items
}

#---------------------------------------------------------------
#
#   Called from menu items
#
#---------------------------------------------------------------

menu_generate_part() {
    # Generate one menu segment
    # log_it "menu_generate_part($1)"

    menu_idx="$1"
    shift # get rid of the idx param
    $cfg_use_cache && f_cache_file="$d_menu_cache/$menu_idx"

    # needs to be set even if this is an empty dynamic menu to prevent
    # static_files_reduction() from running
    $is_dynamic_content && dynamic_content_found=true

    [ -z "$2" ] && {
        # no params clear cache file if any
        $cfg_use_cache && {
            rm -f "$f_cache_file" || error_msg "Failed to remove $f_cache_file"
        }
        return
    }

    if $is_dynamic_content; then
        _mgp_prefix="is_dynamic_content - "
    else
        _mgp_prefix=""
    fi
    ${all_helpers_sourced:-false} || source_all_helpers "$_mgp_prefix menu_generate_part($menu_idx)"

    wt_actions=""
    menu_parse "$@"
    $cfg_use_whiptail && update_wt_actions
}

#---------------------------------------------------------------
#
#   Display Commands related
#
#---------------------------------------------------------------

display_commands_toggle() {
    menu_part="$1"
    # log_it "display_commands_toggle($menu_part)"
    [ -z "$menu_part" ] && error_msg "add_display_commands() - called with no param"

    # In case we got here via dynamic_content()
    ${all_helpers_sourced:-false} || source_all_helpers "display_commands_toggle()"

    set_display_command_labels
    set -- \
        0.0 E ! "$_lbl_next" "show_cmds_state='$_idx_next' $0"

    menu_generate_part "$menu_part" "$@"
}

prepare_show_commands() {
    # Do not use normal caching, build custom menu including cmds under each
    # action item
    # log_it "prepare_show_commands()"

    # Do this before the timer is started, otherwise the first usage of show commands
    # will always be slower
    ${all_helpers_sourced:-false} || source_all_helpers "prepare_show_commands"
    [ ! -f "$f_cached_tmux_key_binds" ] && {
        log_it "Creating: $f_cached_tmux_key_binds"
        # Filtering out all key binds displaying a menu, since they won't be relevant
        $TMUX_BIN list-keys | grep -iv display-menu >"$f_cached_tmux_key_binds"
    }

    safe_now t_show_cmds
    cfg_use_cache=false
    b_do_show_cmds=true
    set_display_command_labels
    tmux_error_handler display-message "Preparing $_lbl ..."
    # shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
    . "$D_TM_BASE_PATH"/scripts/show_cmd.sh
}

#---------------------------------------------------------------
#
#   Environment checks
#
#---------------------------------------------------------------

check_menu_min_vers() {
    # Abort with error if tmux version is insufficient for this menu
    # Shouldn't happen in normal menu navigation.
    # The menu above should have used the same ves number as minima to display
    # a link to this sub-menu.
    # The typical case for this error would be if the menu was run directly from
    # the cmd-line
    tmux_vers_check "$menu_min_vers" || {
        error_msg "$rn_current_script needs tmux: $menu_min_vers"
    }
}

check_screen_size() {
    #
    #  Only consider checking win size if not whiptail/dialog, since they
    #  can scroll menus that don't fit the screen
    #
    #  Only checks if menu_width and or menu_height has been set
    #
    #  Examining client_height instead of menu_height, includes the entire terminal
    #  including lines covered by a status bar. Since Menus can cover the status bar
    #  This gives the actual screen limits for menus
    #
    $cfg_use_whiptail && return 0
    # log_it "check_screen_size()"

    ${all_helpers_sourced:-false} || source_all_helpers "check_screen_size()"

    tmux_vers_check 1.7 || {
        # Prior to 1.7 #{client_height} and #{client_width} are not available
        return 0
    }

    [ -n "$menu_height" ] && {
        [ -z "$current_screen_rows" ] && get_screen_size_variables # only get if not defined
        [ "$menu_height" -gt "$current_screen_rows" ] && {
            _warn="$rn_current_script - aborted, win height > actual: "
            _warn="$_warn $menu_height > $current_screen_rows"
            log_it "$_warn"
            return 1
        }
    }
    [ -n "$menu_width" ] && {
        [ -z "$current_screen_cols" ] && get_screen_size_variables # only get if not defined
        [ "$menu_width" -gt "$current_screen_cols" ] && {
            _warn="menu display aborted, win width > actual: "
            _warn="$_warn $menu_width > $current_screen_cols"
            log_it "$_warn"
            return 1
        }
    }
    return 0
}

oversized_check() {
    # To minimize overhead, the normal case is to rely on oversized menus instantly
    # closing and the displayal of the warning: Screen might be too small
    #
    # only do this check if it is requested, this assumes at least one of
    # menu_height or menu_width must have been set
    #
    [ -z "$menu_height" ] && [ -z "$menu_width" ] && {
        _m="With neither menu_height or menu_width defined"
        _m="$_m\n It is not possible to check if menu fits on screen"
        error_msg "$_m"
    }

    # Useful for hints, if it doesn't fit on screen, just silently skip this menu
    check_screen_size || exit 0
}

#---------------------------------------------------------------
#
#   Preparing menu
#
#---------------------------------------------------------------

set_menu_env_variables() {
    # log_it "set_menu_env_variables()"
    #
    #  Needs to be done for every menu even if caching is done,
    #  since the cache might refer to tmux variables like menu_name

    #
    # State of menu generating process
    #
    is_dynamic_content=false    # indicates if a dynamic content segment is being processed
    dynamic_content_found=false # indicate dynamic content was generated
    static_cache_updated=false  # used to decide if static cache file reduction should happen
    b_do_show_cmds=false

    d_odd_chars="$d_items/odd_chars"

    if [ "$cfg_use_whiptail" = true ]; then
        # Display Commands can only be used with tmux menus and caching
        cfg_display_cmds=false
        unset show_cmds_state
    fi

    case "$show_cmds_state" in
        "1" | "2") prepare_show_commands ;;
        *) ;;
    esac

    #
    #  Per menu overrides of Styling
    #
    [ -n "$override_title" ] && cfg_format_title="$override_title"
    [ -n "$override_selected" ] && cfg_simple_style_selected="$override_selected"
    [ -n "$override_border" ] && cfg_simple_style_border="$override_border"
    [ -n "$override_style" ] && cfg_simple_style="$override_style"
    [ -n "$override_next" ] && cfg_nav_next="$override_next"
    [ -n "$override_prev" ] && cfg_nav_prev="$override_prev"
    [ -n "$override_home" ] && cfg_nav_home="$override_home"
    #
    # allow for having shorter variable names in menus
    #
    {
        nav_next="$cfg_nav_next"
        nav_prev="$cfg_nav_prev"
        nav_home="$cfg_nav_home"
    }

    if $cfg_use_cache; then
        # Include relative script path in cache folder name to avoid name collisions
        #  items/main.sh -> cache/items/main.sh/
        d_menu_cache="$d_cache/$rn_current_script"

        $cfg_use_whiptail && d_wt_actions="$d_menu_cache/wt_actions"
    else
        uncached_menu=""
        uncached_wt_actions=""
        uncached_item_splitter="||||"
    fi

    if $cfg_use_whiptail; then
        external_action_separator=":/:/:/:"
        #
        #  I haven't been able do to menu reload with whiptail/dialog yet,
        #  so disabled for now
        #
        runshell_reload_mnu="\; run-shell \"$f_ext_dlg_trigger $(realpath "$0")\""
        mnu_reload_direct=""
    else
        # built in menu handler doesn't ever seem to need \;
        runshell_reload_mnu=" ; run-shell $0"
        mnu_reload_direct=" ; $0"
    fi

}

static_files_reduction() {
    #
    # if only static content was generated, compact all parts into one
    # for quicker cache loading
    #
    # this is not performance critical
    #
    $dynamic_content_found && {
        error_msg "static_files_reduction() called when dynamic content was generated"
    }
    # log_it "static_files_reduction()"
    cache_read_menu_items
    for f_name in "$d_menu_cache"/*; do
        [ -d "$f_name" ] && continue
        rm "$f_name" || error_msg "static_files_reduction() - failed to remove: $f_name"
    done
    echo "$menu_items" >"$d_menu_cache/1" || {
        error_msg "static_files_reduction Failed to write"
    }
}

cache_regenerate_static_content() {
    # Cache is missing or obsolete, regenerate it
    [ -d "$d_menu_cache" ] && log_it_minimal "$rn_current_script changed - dropping cache"
    # log_it "  regenerate cache for: $d_menu_cache"
    ${all_helpers_sourced:-false} || {
        source_all_helpers "cache_static_content() - cache generation"
    }
    safe_remove "$d_menu_cache" "cache_static_content() - remove previous item"
    mkdir -p "$d_menu_cache" || error_msg "Failed to create: $d_menu_cache"

    run_if_found static_content && static_cache_updated=true
}

cache_static_content() {
    #
    # Ensure the cache folder is present, and newer than the menu file, making sure
    # obsolete cache is dropped.
    #
    if [ "$validate_menu_cache" = 1 ]; then
        # Check freshness
        _csc_mtimr_caller="$(get_mtime "$0")"
        _csc_cache="$(get_mtime "$d_menu_cache")"
        if [ ! -d "$d_menu_cache" ] || [ "$_csc_mtimr_caller" -gt "$_csc_cache" ]; then
            cache_regenerate_static_content
        fi
    else
        # Normal: trust cache if it exists
        [ ! -d "$d_menu_cache" ] && cache_regenerate_static_content
    fi
}

handle_dynamic() {
    #
    # For performance reasons, source_all_helpers() are not called here
    # it is only called if menu_generate_part is called with men definition data
    # So if the full env is needed in a dynamic_content function, it needs
    # to be called there
    #

    # log_it "handle_dynamic()"
    is_function_defined dynamic_content || return

    wt_actions_static="$wt_actions"
    wt_actions=""
    is_dynamic_content=true
    $cfg_use_cache && mkdir -p "$d_menu_cache" # needed if menu is purely dynamic
    dynamic_content
    is_dynamic_content=false
    wt_actions="$wt_actions_static"
}

cache_read_menu_items() {
    #
    # Provides: menu_items
    #
    menu_items=""

    # Exit early if no files exist (protects against empty directory glob issue)
    set -- "$d_menu_cache"/*
    [ -f "$1" ] || return # no files found

    for f_name in "$d_menu_cache"/*; do
        [ -d "$f_name" ] && continue # most likely a wt_actions/

        # Read the content of the files line-by-line and append to the menu_items variable
        while IFS= read -r line || [ -n "$line" ]; do
            if [ -z "$menu_items" ]; then
                menu_items="$line"
            else
                menu_items="$menu_items $line"
            fi
        done <"$f_name"
    done
    # [ -n "$menu_items" ] && debug_print "cache_read_menu_items() found: [$menu_items]"
}

sort_uncached_menu_items() {
    #
    # Since dynamic_content is generated after static_content, it can't be assumed
    # that the menu fragments were generated in proper order, in addition the
    # display_commands_toggle segment will not be generated when caching is disabled.
    # adding gaps in the segment sequence.
    #
    # One of the no-cache assumptions is that tmp files can't be used, so all this put
    # together, leads to this rather hackish in-memory implementation of sorting
    # the uncached_menu clearly lots of room for improvement...
    #
    # log_it "sort_uncached_menu_items()"

    _sumi_entries=""

    _sumi_rest="$uncached_menu"
    while :; do
        case "$_sumi_rest" in
            *"$uncached_item_splitter"*)
                _sumi_part=${_sumi_rest%%"$uncached_item_splitter"*}
                _sumi_rest=${_sumi_rest#*"$uncached_item_splitter"}
                ;;
            *)
                _sumi_part=$_sumi_rest
                _sumi_rest=''
                ;;
        esac

        idx=${_sumi_part%% *}       # First word
        _sumi_body=${_sumi_part#* } # Everything after first space
        # Save as index<TAB>content
        #region  gmi item separation
        _sumi_entries="$_sumi_entries
$idx	$_sumi_body"
        #endregion

        [ -z "$_sumi_rest" ] && break
    done

    # Now sort and print, skipping initial empty line
    menu_items="$(
        printf "%s\n" "$_sumi_entries" | sed 1d | sort -n | while IFS='	' read -r idx this_section; do
            printf '%s' "$this_section" # send it back to the script
        done
    )"
}

get_menu_items_sorted() {
    # log_it "get_menu_items_sorted()"
    if $cfg_use_cache; then
        cache_read_menu_items
    else
        sort_uncached_menu_items
    fi
}

prepare_menu() {
    #
    #  If a menu needs to handle a param, save it before sourcing this using:
    #  menu_param="$1"
    #  then process it in dynamic_content()
    #
    # log_it "prepare_menu()"

    set_menu_env_variables

    # 1 - Handle static parts, use cache if enabled and available
    if $cfg_use_cache; then
        cache_static_content
    else
        run_if_found static_content
    fi

    # 2 - Handle dynamic parts (if any)
    handle_dynamic

    $static_cache_updated && ! $dynamic_content_found && static_files_reduction

    # 3 - Gather each item in correct order
    get_menu_items_sorted

    case "$show_cmds_state" in
        "1" | "2") clear_prep_disp_status ;;
        *) ;;
    esac

    [ -n "$cfg_log_file" ] && {
        # If logging is disabled - no point in generating this log msg
        #
        # Instead of displaying processing time at end of prepare_menu

        time_span "$t_script_start"

        _m="Menu $rn_current_script"
        _m="$_m - processing time:  $t_time_span"
        log_it_minimal "$_m"
    }
}

#---------------------------------------------------------------
#
#   Display menu and handling Screen size
#
#---------------------------------------------------------------

ensure_menu_fits_on_screen() {
    #
    #  Since tmux display-menu returns 0 even if it failed to display the
    #  menu due to not fitting on the screen, the display time is checked.
    #  If it seems to have closed right away, display a message that there
    #  might be a screen size issue.
    #
    #  This is not ideal, since a very slow computer might take some time
    #  for this, and if the user hits q right away, this message will also
    #  be displayed.
    #
    #  This gets slightly more complicated with tmux 3.3, since now tmux
    #  shrinks menus that don't fit due to width, so tmux might decide it
    #  can show a menu, but due to shrinkage, the labels might be so
    #  shortened that they are off little help explaining what the option
    #  would do.
    #
    # Display time menu was shown
    time_span "$dh_t_start"

    # _s="ensure_menu_fits_on_screen() Menu $bn_current_script - "
    # _s="$_s Display time:  $disp_time ($t_minimal_display_time)"
    # log_it "$_s"

    [ "$(echo "$t_time_span < $t_minimal_display_time" | bc || true)" -eq 1 ] && {
        ${all_helpers_sourced:-false} || {
            _m="ensure_menu_fits_on_screen() - short display time, give warning"
            source_all_helpers "$_m"
        }
        #
        # Save menu that failed to show, helpful to try to figure out why it failed
        #
        # _f_mnu="$d_tmp"/tmux-menus-failed-to-show.cmd
        # echo "$menu_items" >"$_f_mnu"
        # log_it "Failed menu saved to: $_f_mnu"

        if [ -n "$menu_width" ] && [ -n "$menu_height" ]; then
            _s="$rn_current_script: screen mins: ${menu_width}x$menu_height"
        elif [ -n "$menu_height" ]; then
            _s="$rn_current_script: Height required: $menu_height"
        elif [ -n "$menu_width" ]; then
            _s="$rn_current_script: Width required: $menu_width"
        else
            # log_it "display time was: $t_time_span"
            _s="$rn_current_script: Screen might be too small - menu closed after $t_time_span"
        fi
        error_msg "$_s"
    }
}

wt_cached_selection() {
    #
    #  Public variables
    #   all_wt_actions - lists all actions
    #
    # log_it "wt_cached_selection()"
    all_wt_actions=""
    for file in "$d_wt_actions"/*; do

        # Check if the file is a regular file
        [ -f "$file" ] && {
            _file_content=""
            while IFS= read -r line || [ -n "$line" ]; do
                _file_content="${_file_content:+$_file_content }$line"
            done <"$file"

            all_wt_actions="$all_wt_actions $_file_content"
            menu_items="$menu_items $_file_content"
        }
    done
}

alt_parse_output() {
    log_it "alt_parse_output()"
    #  $(tmux_escape_for_display "$1")

    #region display whiptail output
    msg="$(
        cat <<EOF
$1

--------------------------------
Output of command above  -  To scroll back in this message:
 <prefix>-[ then up/down arrows

Press Ctrl-C to close this message
EOF
    )"
    #endregion
    f_output="$d_safe_tmp_folder"/cmd_output
    echo "$msg" >"$f_output"
    (
        # run this in the background so that the potentially backgrounded app
        # can be resumed before this tmp window is created, otherwisw 'fg'
        # would be sent to this temp window.
        # If sleep calculation fails, revert to 1 second
        sleep "${t_minimal_display_time:-1}"

        tmux_error_handler new-window -n "output" "cat $f_output ; sleep 7200"
        sleep 1 # argh the remove happens before the above cat without this sleep...
        safe_remove "$f_output" "alt_parse_output()"
    ) &
}

alt_parse_selection() {
    #
    #  Whiptail/dialog can only display selected keyword,
    #  so a post menu step is needed matching keyword with intended
    #  action, and then perform it
    #
    wt_actions="$1"
    # log_it "alt_parse_selection($wt_action)"
    [ -z "$wt_actions" ] && {
        error_msg "alt_parse_selection() - called without param"
    }

    lst=$wt_actions
    i=0
    while true; do
        # POSIX way to handle array types of data
        section="${lst%%"${external_action_separator}"*}" # up to first colon excluding it
        lst="${lst#*"${external_action_separator}"}"      # after fist colon

        i=$((i + 1))
        [ "$i" -gt 50 ] && break
        [ -z "$section" ] && continue # skip blank lines

        key="$(echo "$section" | cut -d'|' -f 1 | awk '{$1=$1};1')"
        _aps_action="$(echo "$section" | cut -d'|' -f 2 | awk '{$1=$1};1')"

        [ "$key" = "$menu_selection" ] && [ -n "$_aps_action" ] && {
            ${all_helpers_sourced:-false} || source_all_helpers "alt_parse_selection()"
            # too many arguments (need at most 2) - fixed by eval
            # teh_debug=true
            eval "$_aps_action"
            [ -n "$wt_output" ] && alt_parse_output "$wt_output"
            break
        }
        [ -z "$lst" ] && break # we have processed last group
    done
}

handle_wt_selecion() {
    # log_it "handle_wt_selecion($menu_selection)"
    if $cfg_use_cache; then
        wt_cached_selection
    else
        all_wt_actions="$uncached_wt_actions"
    fi
    alt_parse_selection "$all_wt_actions"
    unset all_wt_actions
}

clear_prep_disp_status() {
    time_span "$t_show_cmds"
    set_display_command_labels
    log_it "$rn_current_script - Preparing $_lbl took: ${t_time_span}s"

    if tmux_vers_check 3.2; then
        tmux_error_handler display-message -d 1 ""
    else
        # Older tmuxes don't have the time out feature, so the
        # empty message will remain potentially until a key-press
        tmux_error_handler display-message ""
    fi
}

display_menu() {
    # log_it "display_menu()"
    # Display time to generate menu

    if $cfg_use_whiptail; then
        # display whiptail menu
        menu_selection=$(eval "$menu_items" 3>&2 2>&1 1>&3)
        menu_exit_code="$?"
        case "$menu_exit_code" in
            0) ;;
            1)
                [ -n "$menu_selection" ] && {
                    # no selection = menu canceled
                    display_invalid_menu_error "$menu_selection"
                }
                ;;
            *)
                display_invalid_menu_error "$menu_selection"
                ;;
        esac

        [ -n "$menu_selection" ] && handle_wt_selecion
        true #  hides none true exit if whiptail menu was cancelled
    else
        safe_now dh_t_start
        f_cmd_err="$d_tmp/tmux-menu-cmd-error"
        _dm_err_msg="$(cat "$f_cmd_err")"
        eval "$menu_items" 2>"$f_cmd_err" || {
            display_invalid_menu_error "$_dm_err_msg"
        }
        ensure_menu_fits_on_screen
    fi
}

do_menu_handling() {
    [ "$log_file_forced" = 1 ] && {
        # Useful when debugging to keep each menu generation process separate
        log_it
        log_it
        log_it
        log_it
        log_it
    }
    # log_it "do_menu_handling()"

    #
    # Some env checks
    #
    [ -z "$menu_name" ] && error_msg "menu_name not defined"
    [ -n "$menu_min_vers" ] && check_menu_min_vers
    [ "$skip_oversized" = "1" ] && oversized_check

    menu_debug="" # Set to 1 to use echo 2 to use log_it

    prepare_menu
    [ "$TMUX_MENUS_NO_DISPLAY" != "1" ] && display_menu

    # log_it "[$$]   COMPLETED: scripts/menu_handling.sh - $rn_current_script"
    return 0 # ensuring this exits true
}

#===============================================================
#
#   Main
#
#===============================================================

[ -z "$D_TM_BASE_PATH" ] && {
    # helpers not yet sourced, so error_msg() not yet available
    msg="ERROR: menu_handling.sh - D_TM_BASE_PATH must be set before sourcing this file"
    (
        echo
        echo "$msg"
        echo
    ) >/dev/stderr
    exit 1
}

# Only import if needed, checking a random variable
[ -z "$d_scripts" ] && {
    # shellcheck source=tools/variables_meta.sh # faking external variables for shellcheck
    . "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh
}

[ "$no_auto_menu_handling" != 1 ] && do_menu_handling
