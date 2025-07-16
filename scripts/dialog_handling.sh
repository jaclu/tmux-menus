#!/bin/sh
# This script is sourced. Fake shebang to assist editors and linters.
#
#   Copyright (c) 2023–2025: Jacob.Lundqvist@gmail.com
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
    _fname="$1"
    if [ "$(uname)" = "Darwin" ]; then
        # macOS version
        stat -f "%m" "$_fname"
    else
        # Linux version
        stat -c "%Y" "$_fname"
    fi
}

debug_print() {
    case "$menu_debug" in
    "") ;; # not active
    1) print_stderr "$1" ;;
    2) log_it "$1" ;;
    *)
        error_msg_safe "$menu_debug state invalid [$menu_debug] should be 1 or 2! p1[$1]"
        ;;
    esac
}

starting_with_dash() {
    #
    #  In whiptail/dialog, an initial '-'' in a label causes the menu to
    #  fail, in tmux menus this is used to indicate dimmed (disabled)
    #  entries, for whiptail/dialog entries with such labels are just
    #  ignored
    #
    if [ "$(printf '%s' "$1" | cut -c 1)" = "-" ]; then
        return 0
    else
        return 1
    fi
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

    #region error_msg_safe explaining parsing error
    error_msg_safe "$(
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
        log_it "  - NOT runable!"
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
    #region m_menu_code = Display the generated menu code
    m_menu_code="$(
        cat <<EOF

Menu Exit code: $menu_exit_code

Generated menu below

-----   menu start   -----
$menu_items
-----    menu end    -----
$(
            [ -n "$d_menu_cache" ] && {
                printf '\nThe original cached snippets that generated the above,'
                printf ' can be found here:\n  %s/\n\n' "$d_menu_cache"
            }
        )
EOF
    )"
    #endregion

    error_msg_safe "$e_msg\n$e_first\n$m_menu_code"
}

#---------------------------------------------------------------
#
#   Processing menu items
#
#---------------------------------------------------------------

mnu_prefix() {

    _title="$(echo "$cfg_format_title" | sed "s/#{@menu_name}/$menu_name/g")"
    # shellcheck disable=SC2154 # cfg_mnu_loc_x & cfg_mnu_loc_y are defined in settings
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
    label="$1"
    key="$2"
    # cmd="$3"
    cmd="$(echo "$3" | sed 's/"/\\"/g')" # replace embedded " with \"
    # [ -n "$menu_debug" ] && debug_print "mnu_external_cmd($label,$key,$cmd)"

    #
    #  needs to be prefixed with run-shell, since this is triggered by
    #  tmux
    #
    menu_items="$menu_items \"$label\" $key 'run-shell \"$cmd\"'"
}

mnu_command() {
    label="$1"
    key="$2"
    # cmd="$3"
    cmd="$(echo "$3" | sed 's/"/\\"/g')" # replace embedded " with \"

    # [ -n "$menu_debug" ] && debug_print "mnu_command($label,$key,$cmd)"
    menu_items="$menu_items \"$label\" $key \"$cmd\""
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
    label="$1"
    key="$2"
    menu="$3"

    #
    #  labels starting with - indicates disabled feature in tmux notation,
    #  whiptail can not handle labels starting with -, so just skip
    #  those lines
    #
    starting_with_dash "$label" && return

    menu_items="$menu_items $key \"$label\""
    wt_actions="$wt_actions $key | $menu $external_action_separator"
}

alt_external_cmd() {
    label="$1"
    key="$2"
    cmd="$3"

    #
    #  labels starting with - indicates disabled feature in tmux notation,
    #  whiptail can not handle labels starting with -, so just skip
    #  those lines
    #
    starting_with_dash "$label" && return

    menu_items="$menu_items $key \"$label\""
    # This will run outside tmux, so should not have run-shell prefix
    wt_actions="$wt_actions $key | $cmd $external_action_separator"
}

alt_command() {
    # filtering out tmux #{...} & #[...] sequences
    label="$(echo "$1" | sed 's/#{[^}]*}//g' | sed 's/#\[[^}]*\]//g')"
    key="$2"
    cmd="$3"

    #
    #  labels starting with - indicates disabled feature in tmux notation,
    #  whiptail can not handle labels starting with -, so just skip
    #  those lines
    #
    starting_with_dash "$label" && return

    # filer out backslashes prefixing special chars
    key_action="$(echo "$key" | sed 's/\\//')"

    menu_items="$menu_items $key \"$label\""
    wt_actions="$wt_actions $key_action | tmux_error_handler_assign wt_output $cmd $external_action_separator"
}

alt_text_line() {
    #
    #  filtering out tmux #{...} sequences and initial -
    #  labels starting with - indicates disabled feature,
    #  whiptail can not handle labels starting with -, so remove it
    #
    txt="$(echo "$1" | sed 's/^[-]//' | sed 's/#\[[^]]*\]//g')"

    [ "$(printf '%s' "$txt" | cut -c1)" = "-" ] && {
        txt=" ${txt#?}"
    }

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
    [ -z "$_key" ] && error_msg_safe "Key was empty for: $_item in: $0"
}

menu_parse() {
    #
    #  Since the various menu entries have different numbers of params
    #  we first identify all the params used by the different options,
    #  only then can we continue if the min_vers does not match running tmux
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
        min_vers="$1"
        shift
        action="$1"
        shift

        [ -n "$menu_debug" ] && debug_print "-- parsing an item [$min_vers] [$action]"
        case "$action" in

        "C")
            #  direct tmux command - params: key label task
            key="$1"
            shift
            label="$1"
            shift
            cmd="$1"
            shift

            # first extract the variables, then  if it shouldn't be used move on
            ! tmux_vers_check "$min_vers" && continue

            verify_menu_key "$key" "tmux command: $cmd"

            [ -n "$menu_debug" ] && debug_print "key[$key] label[$label] command[$cmd]"

            if $cfg_use_whiptail; then
                alt_command "$label" "$key" "$cmd"
            else
                mnu_command "$label" "$key" "$cmd"
                $b_do_show_cmds && sc_show_cmd "$TMUX_BIN $cmd"
            fi
            ;;

        E)
            #
            #  Run external command - params: key label cmd
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
            key="$1"
            shift
            label="$1"
            shift
            cmd="$1"
            shift

            # first extract the variables, then  if it shouldn't be used move on
            ! tmux_vers_check "$min_vers" && continue

            verify_menu_key "$key" "external command: $cmd"

            [ -n "$menu_debug" ] && debug_print "key[$key] label[$label] command[$cmd]"

            if $cfg_use_whiptail; then
                alt_external_cmd "$label" "$key" "$cmd"
            else
                mnu_external_cmd "$label" "$key" "$cmd"
                $b_do_show_cmds && [ "$key" != "!" ] && sc_show_cmd "$cmd"
            fi
            ;;

        "M")
            #  Open another menu
            key="$1"
            shift
            label="$1"
            shift
            menu="$1"
            shift

            # first extract the variables, then  if it shouldn't be used move on
            ! tmux_vers_check "$min_vers" && continue

            verify_menu_key "$key" "$menu"

            #
            #  If menu is not full PATH, assume it to be a tmux-menus
            #  item
            #
            case $menu in
            */*) ;;
            *) menu="$d_items/$menu" ;;
            esac

            [ -n "$menu_debug" ] && debug_print "key[$key] label[$label] menu[$menu]"

            if $cfg_use_whiptail; then
                alt_open_menu "$label" "$key" "$menu"
            else
                mnu_open_menu "$label" "$key" "$menu"
            fi
            ;;

        "T")
            #  text line - params: txt
            txt="$1"
            shift

            # first extract the variables, then  if it shouldn't be used move on
            ! tmux_vers_check "$min_vers" && continue

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
            ! tmux_vers_check "$min_vers" && continue

            [ -n "$menu_debug" ] && debug_print "Spacer line"

            # Whiptail/dialog does not have a concept of spacer lines
            if $cfg_use_whiptail; then
                alt_spacer
            else
                mnu_spacer
            fi
            ;;

        *) mnu_parse_error "$action" "$@" ;;
        esac
    done

    if $cfg_use_cache; then
        log_it_minimal "Caching: $(relative_path "$f_cache_file")"
        echo "$menu_items" >"$f_cache_file" || {
            error_msg_safe "Failed to write to: $f_cache_file"
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
        log_it "><> menu_generate_part() - clear: $f_cache_file"
        $cfg_use_cache && rm -f "$f_cache_file"
        return
    }

    if $is_dynamic_content; then
        _mgp_prefix="is_dynamic_content - "
    else
        _mgp_prefix=""
    fi
    $all_helpers_sourced || source_all_helpers "$_mgp_prefix menu_generate_part($menu_idx)"

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
    $all_helpers_sourced || source_all_helpers "display_commands_toggle()"

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
    $all_helpers_sourced || source_all_helpers "prepare_show_commands"
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
    # shellcheck source=scripts/show_cmd.sh
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
        error_msg_safe "$rn_current_script needs tmux: $menu_min_vers"
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

    $all_helpers_sourced || source_all_helpers "check_screen_size()"

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
        error_msg_safe "$_m"
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

    # shellcheck disable=SC2034 # Used by currencies and diacritics menus
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
    # shellcheck disable=SC2034
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
    echo "$menu_items" >"$d_menu_cache/1"
}

cache_static_content() {
    #
    # Ensure the cache folder is present, and newer than the menu file, making sure
    # obsolete cache is dropped.
    #
    # log_it "cache_static_content() - [$0] d_menu_cache [$d_menu_cache]"
    if [ ! -d "$d_menu_cache" ] || [ "$(get_mtime "$0")" -gt "$(get_mtime "$d_menu_cache")" ]; then
        # Cache is missing or obsolete, regenerate it
        [ -d "$d_menu_cache" ] && log_it_minimal "$rn_current_script changed - dropping cache"
        # log_it "  regenerate cache for: $d_menu_cache"
        $all_helpers_sourced || {
            source_all_helpers "cache_static_content() - cache generation"
        }
        safe_remove "$d_menu_cache" "cache_static_content()"
        mkdir -p "$d_menu_cache" || error_msg "Failed to create: $d_menu_cache"

        run_if_found static_content && static_cache_updated=true
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
    for f_name in "$d_menu_cache"/*; do
        [ -d "$f_name" ] && continue # most likely a wt_actions/

        # Read the content of the file and append it to the menu_items variable
        if [ -z "$menu_items" ]; then
            menu_items="$(cat "$f_name")"
        else
            menu_items="$menu_items $(cat "$f_name")"
        fi
    done
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

    gmi_entries=""

    gmi_rest="$uncached_menu"
    while :; do
        case "$gmi_rest" in
        *"$uncached_item_splitter"*)
            gmi_part=${gmi_rest%%"$uncached_item_splitter"*}
            gmi_rest=${gmi_rest#*"$uncached_item_splitter"}
            ;;
        *)
            gmi_part=$gmi_rest
            gmi_rest=''
            ;;
        esac

        idx=$(printf "%s" "$gmi_part" | cut -d' ' -f1)
        gmi_body=$(printf "%s" "$gmi_part" | cut -d' ' -f2-)
        # Save as index<TAB>content
        #region  gmi item separation
        gmi_entries="$gmi_entries
$idx	$gmi_body"
        #endregion

        [ -z "$gmi_rest" ] && break
    done

    # Now sort and print, skipping initial empty line
    menu_items="$(
        printf "%s\n" "$gmi_entries" | sed 1d | sort -n | while IFS='	' read -r idx this_section; do
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

        # shellcheck disable=SC2154 # defined in helpers_minimal.sh
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
    # SC2154: variable assigned dynamically by safe_now using eval in display_menu()
    # shellcheck disable=SC2154
    time_span "$dh_t_start"

    # log_it "ensure_menu_fits_on_screen() Menu $bn_current_script - Display time:  $disp_time ($t_minimal_display_time)"
    [ "$(echo "$t_time_span < $t_minimal_display_time" | bc)" -eq 1 ] && {
        $all_helpers_sourced || {
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
    # log_it "><> display time: $t_time_span"
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
            all_wt_actions="$all_wt_actions $(cat "$file")"
            #
            #  Read the content of the file and append it to
            #  the dialog variable
            #
            menu_items="$menu_items $(cat "$file")"
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
    #  so a post dialog step is needed matching keyword with intended
    #  action, and then perform it
    #
    wt_actions="$1"
    # log_it "alt_parse_selection($wt_action)"
    [ -z "$wt_actions" ] && {
        error_msg_safe "alt_parse_selection() - called without param"
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
        action="$(echo "$section" | cut -d'|' -f 2 | awk '{$1=$1};1')"

        [ "$key" = "$menu_selection" ] && [ -n "$action" ] && {
            $all_helpers_sourced || source_all_helpers "alt_parse_selection()"
            # log_it "><>action: >>$action<<"
            # too many arguments (need at most 2) - fixed by eval
            # teh_debug=true
            eval "$action"
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
    # SC2154: variable assigned dynamically by safe_now using eval in prepare_show_commands()
    # shellcheck disable=SC2154
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
        eval "$menu_items" 2>"$f_cmd_err" || {
            display_invalid_menu_error "$(cat "$f_cmd_err")"
        }
        ensure_menu_fits_on_screen
    fi
}

do_dialog_handling() {
    # shellcheck disable=SC2154 # log_file_forced usually not set
    [ "$log_file_forced" = 1 ] && {
        # Useful when debugging to keep each menu generation process separate
        log_it
        log_it
        log_it
        log_it
        log_it
    }

    #
    # Some env checks
    #
    [ -z "$menu_name" ] && error_msg_safe "menu_name not defined"
    [ -n "$menu_min_vers" ] && check_menu_min_vers
    # shellcheck disable=SC2154 # might be defined in calling menu
    [ "$skip_oversized" = "1" ] && oversized_check

    menu_debug="" # Set to 1 to use echo 2 to use log_it

    prepare_menu
    # shellcheck disable=SC2154 # TMUX_MENUS_NO_DISPLAY is an env variable
    [ "$TMUX_MENUS_NO_DISPLAY" != "1" ] && display_menu

    # log_it "[$$]   COMPLETED: scripts/dialog_handling.sh - $rn_current_script"
    return 0 # ensuring this exits true
}

#===============================================================
#
#   Main
#
#===============================================================

[ -z "$D_TM_BASE_PATH" ] && {
    # helpers not yet sourced, so error_msg_safe() not yet available
    msg="ERROR: dialog_handling.sh - D_TM_BASE_PATH must be set!"
    (
        echo
        echo "$msg"
        echo
    ) >/dev/stderr
    exit 1
}

# Only import if needed, checking a random variable
[ -z "$d_scripts" ] && {
    # shellcheck source=scripts/helpers_minimal.sh
    . "$D_TM_BASE_PATH"/scripts/helpers_minimal.sh
}

# shellcheck disable=SC2154 # no_auto_dialog_handling usually not set
[ "$no_auto_dialog_handling" != 1 ] && do_dialog_handling
