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

    log_it "cache_clear() $1"

    rm -rf "$d_cache"
    mkdir -p "$d_cache"
    b_cache_clear_has_been_called=true
}

cache_add_ok_vers() {
    # log_it "cache_add_ok_vers($1)"
    case "$cache_ok_tmux_versions" in
    *"$1"*) ;;
    *)
        cache_ok_tmux_versions="${cache_ok_tmux_versions}$1 "
        # log_it "Added ok tmux vers: $1"
        cache_save_known_tmux_versions
        ;;
    esac
}

cache_add_bad_vers() {
    # log_it "cache_add_bad_vers($1)"
    case "$cache_bad_tmux_versions" in
    *"$1"*) ;;
    *)
        cache_bad_tmux_versions="${cache_bad_tmux_versions}$1 "
        # log_it "Added bad tmux vers: $1"
        cache_save_known_tmux_versions
        ;;
    esac
}

cache_save_known_tmux_versions() { # tmux stuff
    # log_it "cache_save_known_tmux_versions()"
    $cfg_use_cache || {
        error_msg "cache_save_known_tmux_vers() - called when not using cache"
    }

    #region known tmux versions
    cat <<EOF >"$f_cache_known_tmux_vers"
#!/bin/sh
# Autogenerated always sourced file - Fake bang path to help editors/linters

#
#  This is a list of known good/bad tmux versions, to speed up version checks
#
cache_ok_tmux_versions="$cache_ok_tmux_versions"
cache_bad_tmux_versions="$cache_bad_tmux_versions"
EOF
    #endregion
}

cache_param_write() { # tmux stuff
    # log_it "cache_param_write()"
    $cfg_use_cache || { # extra check preventing inappropriate writes
        error_msg "cache_param_write() - called when not using cache"
    }

    f_params_tmp=$(mktemp) || error_msg "Failed to create config file"

    #region param cache file
    cat <<EOF >"$f_params_tmp"
#!/bin/sh
# Autogenerated always sourced file - Fake bang path to help editors/linters

#  This is a cache of configsfor the plugin.
#  By sourcing this instead of gathering it each time, tons of time
#  is saved

cfg_trigger_key="$(tmux_escape_special_chars "$cfg_trigger_key")"
cfg_no_prefix="$cfg_no_prefix"
cfg_use_cache="$cfg_use_cache"

cfg_format_title="$cfg_format_title"
cfg_simple_style_selected="$cfg_simple_style_selected"
cfg_simple_style="$cfg_simple_style"
cfg_simple_style_border="$cfg_simple_style_border"

cfg_nav_next="$cfg_nav_next"
cfg_nav_prev="$cfg_nav_prev"
cfg_nav_home="$cfg_nav_home"

cfg_mnu_loc_x="$cfg_mnu_loc_x"
cfg_mnu_loc_y="$cfg_mnu_loc_y"
cfg_tmux_conf="$cfg_tmux_conf"

cfg_log_file="$cfg_log_file"
cfg_use_notes="$cfg_use_notes"

tmux_vers="$tmux_vers"
i_tmux_vers="$i_tmux_vers"
EOF
    #endregion

    if [ ! -f "$f_cache_params" ]; then
	log_it "Creating param cache"
	mv "$f_params_tmp" "$f_cache_params"
    elif ! diff -q "$f_params_tmp" "$f_cache_params" >/dev/null 2>&1 ; then
	# diff reports success if files dont fiffer, hence the !
	# If any params have changed, invalidate cache
	log_it "Config changed - clearing cache"
	cache_clear
	mv "$f_params_tmp" "$f_cache_params"
    else
	rm -f "$f_params_tmp" # no changes
    fi
}

cache_update_params() {
    #
    #  Reads plugin options from tmux and save the param cache
    #
    # log_it "cache_update_params()"
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
        vers_cached="$(grep ^tmux_vers= "$f_cache_params" |
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

#===============================================================
#
#   Main
#
#===============================================================

d_cache="$D_TM_BASE_PATH"/cache
f_cache_params="$d_cache"/plugin_params
f_using_whiptail="$d_cache"/using-whiptail
f_cache_known_tmux_vers="$d_cache"/known_tmux_versions
b_cache_has_been_validated=false
b_cache_clear_has_been_called=false

#
#  To indicate that cache should not be used, without writing anything
#  inside the plugin folder, a file in $TMPDIR or /tmp is used
#
_s="$(basename "$(echo "$TMUX" | cut -d, -f 1)")" # extract the socket name
f_cache_not_used_hint="$d_tmp/${plugin_name}-no_cache_hint-$(id -u)-$_s"
