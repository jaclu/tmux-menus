#!/bin/sh
# Always sourced file - Fake bang path to help editors
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Cache related stuff
#
# shellcheck disable=SC2034,SC2154

#---------------------------------------------------------------
#
#   cache handling
#
#---------------------------------------------------------------

cache_clear() { # only cache
    #
    #  Clear cache related files, since this only removes files if found
    #  it can be called also when cache is disabled.
    #

    log_it "cache_clear($1)"

    rm -rf "$d_cache"
    rm -f "$f_cache_tmux_known_vers"
    b_cache_clear_has_been_called=true
}

cache_define_ok_bad_tmux_vers() { # tmux stuff
    #
    #  public variables
    #   tmux_vers - tmux version for this tmux server
    #   tmux_i_ref - int part of tmux_vers, for tmux_vers_check
    #   cache_ok_tmux_versions - known versions tmux_vers_check accepts
    #   cache_bad_tmux_versions - known versions tmux_vers_check rejects
    #

    # log_it "cache_define_ok_bad_tmux_vers($ptvcc_changes)"

    # tmux_set_vers_vars - should have been set
    # TODO: remove this debug check
    [ -n "$tmux_vers" ] || error_msg "cache_define_ok_bad_tmux_vers() - missing tmux_vers" 1 false

    # make sure we dont end up using a previous instance of this
    unset cache_known_tmux_vers
    [ -f "$f_cache_tmux_known_vers" ] || {
        # log_it "><> no vers list found, generating it"
        cache_save_known_tmux_vers
    }

    #
    # get the list of known versions
    #
    # shellcheck disable=SC1090 # file doesnt always exist
    . "$f_cache_tmux_known_vers"

    #
    # Redefube ok vs bad versions to incorporate new version
    #
    cache_ok_tmux_versions=""
    cache_bad_tmux_versions=""
    for ptvcc_vers in $cache_known_tmux_vers; do
        if [ "$(expr "$ptvcc_vers" \< "$tmux_vers")" -eq 1 ]; then
            cache_ok_tmux_versions="$cache_ok_tmux_versions $ptvcc_vers"
        elif [ "$ptvcc_vers" = "$tmux_vers" ]; then
            cache_ok_tmux_versions="$cache_ok_tmux_versions $tmux_vers"
        else
            cache_bad_tmux_versions="$cache_bad_tmux_versions $ptvcc_vers"
        fi
    done

    unset ptvcc_changes
    unset cache_known_tmux_vers
    unset ptvcc_vers
}

# shellcheck disable=SC2120  # called with params from other modules
cache_param_write() { # tmux stuff
    cpw_vers_changes="$1"

    # log_it "cache_param_write($cpw_vers_changes)"
    $cfg_use_cache || { # extra check preventing inapropriate writes
        error_msg "cache_param_write() - called when not using cache"
    }

    mkdir -p "$d_cache"

    if [ "$cpw_vers_changes" = y ]; then
        cache_update_known_tmux_vers "$cpw_vers_changes"
    else
        cache_define_ok_bad_tmux_vers
    fi
    #region param cache file
    cat <<EOF >"$f_cache_params"
#!/bin/sh
# Autogenerated always sourced file - Fake bang path to help editors/linters

#  This is a cache of all tmux options, and some other configs.
#  By sourcing this instead of gathering it each time, tons of time
#  is saved

cfg_trigger_key="$(tmux_escape_special_chars "$cfg_trigger_key")"
cfg_no_prefix="$cfg_no_prefix"
cfg_use_cache="$cfg_use_cache"
cfg_mnu_loc_x="$cfg_mnu_loc_x"
cfg_mnu_loc_y="$cfg_mnu_loc_y"
cfg_tmux_conf="$cfg_tmux_conf"

cfg_log_file="$cfg_log_file"
cfg_use_notes="$cfg_use_notes"

tmux_vers="$tmux_vers"
tmux_i_ref="$tmux_i_ref"
cache_ok_tmux_versions="$cache_ok_tmux_versions"
cache_bad_tmux_versions="$cache_bad_tmux_versions"
EOF
    #endregion
    unset cpw_vers_changes
    # duration="$(echo "$(safe_now) - $pcw_t1" | bc)"
    # time_spent="$time_spent\n cache_param_write - $duration"
}

cache_update_params() { # tmux stuff
    #
    #  will also ensure current tmux conf is used, even if other
    #  settings has already been sourced
    #     tmux_conf should have been defined before calling this
    #

    # log_it "cache_update_params() - gets & saves paramcache"
    tmux_get_plugin_options
    $cfg_use_cache && cache_param_write
}

cache_validation() { # tmux stuff
    #
    #  Clear (and recreate) cache if it was not created with current
    #  tmux version and WHIPTAIL settings
    #
    #  Public variables that might be altered
    #   b_cache_clear_has_been_called
    #   b_cache_has_been_validated
    #

    # log_it "cache_validation()"
    if [ -s "$f_cache_params" ]; then
        vers_actual="$(tmux_get_vers)"
        vers_cached="$(grep tmux_vers= "$f_cache_params" |
            sed 's/"//g' | cut -d'=' -f2)"

        #  compare actual vs cached
        if [ "$vers_actual" != "$vers_cached" ]; then
            cache_clear \
                "Was made for tmux: $vers_cached now using: $vers_actual"
        else
            [ -f "$f_using_whiptail" ] &&
                was_whiptail=true || was_whiptail=false

            if $was_whiptail && [ "$FORCE_WHIPTAIL_MENUS" != 1 ]; then
                cache_clear "No longer using whiptail"
            elif ! $was_whiptail && [ "$FORCE_WHIPTAIL_MENUS" = 1 ]; then
                cache_clear "Now using whiptail"
            fi
        fi
    else
        cache_clear "failed to verify"
    fi

    #  Ensure param cache is current
    if $b_cache_clear_has_been_called || [ ! -f "$f_cache_params" ]; then
        cache_update_params
    fi

    # hint for menus.tmux that it does not need to repeat the action
    b_cache_has_been_validated=true

    unset vers_actual vers_cached was_whiptail
}

cache_update_known_tmux_vers() { # tmux stuff
    #
    #  Public variables
    #   cache_known_tmux_vers
    #
    cuktv_vers_changes="$1"

    log_it "cache_update_known_tmux_vers($cuktv_vers_changes)"

    $cfg_use_cache || {
        error_msg "cache_update_known_tmux_vers() - called when not using cache"
    }

    if [ "$cuktv_vers_changes" = y ]; then
        # if an unrecognized tmux version was detected, add it to this list
        cache_known_tmux_vers="$cache_ok_tmux_versions $cache_bad_tmux_versions"
    fi

    cache_save_known_tmux_vers

    unset cuktv_vers_changes
}

cache_save_known_tmux_vers() { # tmux stuff
    # log_it "cache_save_known_tmux_vers()"

    $cfg_use_cache || {
        error_msg "cache_save_known_tmux_vers() - called when not using cache"
    }

    [ -n "$cache_known_tmux_vers" ] || {
        #
        #  0.0 is a custom version used by tmux-menus, to indicate an
        #      an action that should always be done
        #
        if true; then
            cache_known_tmux_vers="
            0.0
            0.8
            0.9
            1.0
            1.1
            1.2
            1.3
            1.4
            1.5
            1.6
            1.7
            1.8
            1.9
            1.9a
            2.0
            2.1
            2.2
            2.3
            2.4
            2.5
            2.6
            2.7
            2.8
            2.9
            2.9a
            3.0
            3.0a
            3.1
            3.1a
            3.1b
            3.1c
            3.2
            3.2a
            3.3
            3.3
            3.3
            3.3a
            3.4
            "
        else
            # debug that cache can add known versions
            cache_known_tmux_vers=""
        fi
    }

    #region known tmux versions
    cat <<EOF >"$f_cache_tmux_known_vers"
#!/bin/sh
# Autogenerated always sourced file - Fake bang path to help editors/linters

#
#  This is a list of known tmux versions, given in incremental order
#  So that once the running tmux is found, all comming before can be assumed
#  to be prior, ie features depending on such versions should work on the
#  current version
#
cache_known_tmux_vers="$(echo "$cache_known_tmux_vers" | sed 's/ /\n/g' | sort | uniq)"

EOF
    #endregion
}

#===============================================================
#
#   Main
#
#===============================================================

d_cache="$D_TM_BASE_PATH"/cache

# cache plugin params
f_cache_params="$d_cache"/plugin_params
f_using_whiptail="$d_cache"/using-whiptail

#
#  this is created with a list of all known versions of tmux, if an
#  unknown version is encountered, it is added to this file, and will
#  thus be cached for all future runs of any menu
#  It is saved outside the cache dir, in order not to disapear if
#  cache is purged by running a different version of tmux
#  it is in .gitignore, so shouldnt create git pull issues
#
f_cache_tmux_known_vers="$d_scripts"/tmux_vers_list.sh

b_cache_has_been_validated=false
b_cache_clear_has_been_called=false

#
#  If a menu detects an unknown tmux version, saving it right away
#  kills performance if more than one unknown is detected, so instead
#  this flag is used, and then dialog_handling updates the cache file once,
#  after the menu has been processed
#
b_cache_delayed_param_write=false

#
#  To indicate that cache should not be used, without writing anything
#  inside the plugin folder, a file in $TMPDIR or /tmp is used
#
f_cache_not_used_hint="$d_tmp/${plugin_name}-no_cache_hint-${tmux_pid}"
