# helper function calls

## with cache enabled and available

- tmux: tmux_select_menu_handler
- tmux: tmux_vers_check
- tmux: tpt_retrieve_running_tmux_vers
- tmux: tpt_digits_from_string
- tmux: tpt_tmux_vers_suffix
- helpers: get_config
- cacge: cache_get_params
- helpers: safe_now
- helpers: relative_path

### displaying menu

- safe_now
- tmux_error_handler
- safe_now

## with cache enabled if item was missing

these extra support items were called

- tnmux: tmux_vers_check
- helpers: relative_path

## with cache enabled if cache was missing

- tmux_select_menu_handler
- tmux_vers_check
- tpt_retrieve_running_tmux_vers
- tpt_digits_from_string
- tpt_tmux_vers_suffix
- tpt_digits_from_string(3.0)
- cache_add_ok_vers(3.0)
- cache_save_known_tmux_versions- called when not using cache
- cache_save_known_tmux_versions() - ./items/main.sh
- cache_prepare
- cache_create_folder
- get_config
- cache_get_params
- cache_update_param_cache
- tmux_get_plugin_options
- tmux_get_defaults

### sequence for vers check

- tmux_vers_check(3.2)
- tpt_digits_from_string(3.2)
- cache_add_ok_vers
- cache_save_known_tmux_versions() - called when not using cache
- cache_save_known_tmux_versions() - ./items/main.sh
- cache_prepare

- tmux_get_option(@menus_trigger, \)
- tmux_vers_check(1.8)
- tpt_digits_from_string(1.8)
- cache_add_ok_vers(1.8)
- cache_save_known_tmux_versions() - called when not using cache
- cache_save_known_tmux_versions() - ./item/main.sh
- cache_prepare
- tmux_is_option_defined(@menus_use_cache)
- tmux_error_handler(show-options -gq)
- lowercase_it(Yes)
- normalize_bool_param(@menus_use_hint_overlays, Yes) []
-
