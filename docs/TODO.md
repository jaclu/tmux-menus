# Plan

## Workflow cached menu

These should be as performant as possible!

- prepare_menu

  - set_menu_env_variables - checked
    - relative_path - checked
  - cache_static_content - checked
    - get_mtime - checked
  - handle_dynamic - these are always run uncached, so performance is a premium!
    - is_function_defined
    - dynamic_content - various but commonly include
      - menu_generate_part +++ - checked
      - tmux_error_handler_assign ++ - checked
        - validate_varname - checked
      - display_commands_toggle - checked
      - tmux_vers_check - checked
  - get_menu_items_sorted - checked
    - cache_read_menu_items - checked

- display_menu - checked
  - safe_now - checked
  - ensure_menu_fits_on_screen - checked

## tmux 3.4

- @menus_config_file - when HOME is expanded in some cases there are glitches

## Styling

- quotes are not handled correctly for `@menus_format_title`

## WhipTail

- menu_reload is not working, so disabled

## external_tools/dropbox.sh

toggle not working

## Pane titles

Add items, enable/disable show pane titles

## Inspect if this works as intended

has_lf_not_at_end
