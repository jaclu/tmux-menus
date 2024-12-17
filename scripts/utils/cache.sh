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
    if [ -f "$f_cache_not_used_hint" ]; then
        error_msg "cache_clear() - called when not using cache"
        log_it "><> returned from cache_clear() error"
    fi

    rm -rf "$d_cache"

    # Invalidate what might have already been sourced
    cached_ok_tmux_versions=""
    cached_bad_tmux_versions=""
}

cache_prepare() {
    #
    #  Make sure cache folder exists, call this before any cache write
    #
    #  returns 0 if cache folder exists / was created
    #
    [ -d "$d_cache" ] && return 0

    if [ -f "$f_cache_not_used_hint" ]; then
        error_msg "cache_prepare() - called when not using cache" 1
        return 1
    fi

    mkdir -p "$d_cache"
    log_it "cache_prepare() - created: $d_cache"
    return 0
}

cache_add_ok_vers() {
    #
    #  Add param to list of good versions (<=running tmux vers),
    #  if it wasn't cached already
    #
    # log_it "cache_add_ok_vers($1)"
    case "$cached_ok_tmux_versions" in
    *"$1"*) ;;
    *)
        cached_ok_tmux_versions="${cached_ok_tmux_versions}$1 "
        # log_it "Added ok tmux vers: $1"
        cache_save_known_tmux_versions
        ;;
    esac
}

cache_add_bad_vers() {
    #
    #  Add param to list of bad versions (>running tmux vers),
    #  if it wasn't cached already
    #
    # log_it "cache_add_bad_vers($1)"
    case "$cached_bad_tmux_versions" in
    *"$1"*) ;;
    *)
        cached_bad_tmux_versions="${cached_bad_tmux_versions}$1 "
        # log_it "Added bad tmux vers: $1"
        cache_save_known_tmux_versions
        ;;
    esac
}

cache_save_known_tmux_versions() { # tmux stuff
    #
    #  The order the versions are saved doesn't matter,
    #  since they are checked with a case to speed things up
    #
    if [ -f "$f_cache_not_used_hint" ] || ! $cfg_use_cache; then
        log_it "cache_save_known_tmux_versions() - called when not using cache"
        return 1
    fi
    # log_it "cache_save_known_tmux_versions()"

    cache_prepare

    #region known tmux versions
    cat <<EOF >"$f_cache_known_tmux_vers" || error_msg "Failed to save known versions" 1
#!/bin/sh
# Autogenerated always sourced file - Fake bang path to help editors/linters

#
#  This is a list of known good/bad tmux versions, to speed up version checks
#
cached_ok_tmux_versions="$cached_ok_tmux_versions"
cached_bad_tmux_versions="$cached_bad_tmux_versions"
EOF
    #endregion
}

cache_param_write() { # tmux stuff
    #
    #  Writes all config params to file
    #  if it differed with previous params, clear cache
    #
    log_it "cache_param_write()"
    if [ -f "$f_cache_not_used_hint" ] || ! $cfg_use_cache; then
        error_msg "cache_param_write() - called when not using cache"
    fi

    cd "$D_TM_BASE_PATH" || error_msg "Failed to cd into $D_TM_BASE_PATH"
    repo_last_changed="$(git log -1 --format="%ad" --date=iso 2>/dev/null)"
    [ -z "$repo_last_changed" ] && log_it "repo_last_changed - empty!"
    f_params_tmp=$(mktemp) || error_msg "Failed to create tmp config file"

    cache_prepare
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
cfg_use_whiptail="$cfg_use_whiptail"

cfg_nav_next="$cfg_nav_next"
cfg_nav_prev="$cfg_nav_prev"
cfg_nav_home="$cfg_nav_home"

cfg_format_title="$cfg_format_title"
cfg_simple_style="$cfg_simple_style"
cfg_simple_style_border="$cfg_simple_style_border"
cfg_simple_style_selected="$cfg_simple_style_selected"

cfg_mnu_loc_x="$cfg_mnu_loc_x"
cfg_mnu_loc_y="$cfg_mnu_loc_y"

cfg_tmux_conf="$cfg_tmux_conf"
cfg_log_file="$cfg_log_file"

cfg_use_notes="$cfg_use_notes"

tmux_vers="$tmux_vers"
i_tmux_vers="$i_tmux_vers"

# get a version hint, this also ensures cache is cleared anytime
# repo was updated
repo_last_changed="$repo_last_changed"

EOF
    #endregion
    unset repo_last_changed

    if [ ! -f "$f_cache_params" ]; then
        log_it "  cache_param_write() - Creating param cache"
        mv "$f_params_tmp" "$f_cache_params"
    elif ! diff -q "$f_params_tmp" "$f_cache_params" >/dev/null 2>&1; then
        # diff reports success if files dont fiffer, hence the !
        # If any params have changed, invalidate cache
        # log_it "  cache_param_write() - Config changed - clear cache"
        cache_clear "Environment changed"
        log_it "  cache_param_write() - Saving new param cache"
        mv "$f_params_tmp" "$f_cache_params"
    else
        rm -f "$f_params_tmp" # no changes
        # ensure time stamp is updated for tmux.conf age comparisons
        touch "$f_cache_params"
    fi
    return 0
}

cache_update_param_cache() {
    #
    #  Reads plugin options from tmux and save the param cache
    #
    # log_it "cache_update_param_cache()"
    tmux_get_plugin_options # ensure env is retrieved
    $cfg_use_cache && cache_param_write
}

cache_get_params() {
    #
    #  Retrieves cached env params, returns true on success, otherwise false
    #
    # log_it "cache_get_params()"

    if [ -f "$f_cache_not_used_hint" ]; then
        error_msg "cache_get_params() - called when not using cache"
    fi
    if [ -f "$f_cache_params" ]; then
        # shellcheck disable=SC1090
        . "$f_cache_params" || return 1
        if [ -f "$cfg_tmux_conf" ] &&
            [ -n "$(find "$cfg_tmux_conf" -newer "$f_cache_params" 2>/dev/null)" ]; then
            log_it "$cfg_tmux_conf has been updated, parse again for current settings"
            cache_update_param_cache
        fi
        return 0
    fi
    return 1
}

#===============================================================
#
#   Main
#
#===============================================================

d_cache="$D_TM_BASE_PATH"/cache
f_cache_params="$d_cache"/plugin_params
f_cache_known_tmux_vers="$d_cache"/known_tmux_versions

#
#  To indicate that cache should not be used, without writing anything
#  inside the plugin folder, a file in $TMPDIR or /tmp is used
#
_s="$(basename "$(echo "$TMUX" | cut -d, -f 1)")" # extract the socket name
f_cache_not_used_hint="$d_tmp/${plugin_name}-no_cache_hint-$(id -u)-$_s"
# tmux_get_plugin_options()  will log if f_cache_not_used_hint is used/not
