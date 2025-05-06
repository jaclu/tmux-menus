# Plan

## Workflow cached menu

These should be as performant as possible!

- prepare_menu

  - set_menu_env_variables
    - relative_path
  - cache_static_content
    - get_mtime
  - handle_dynamic - these are always run uncached, so performance is a premium!
    - is_function_defined
    - dynamic_content - various but commonly include
      - menu_generate_part +++ <- investigate!
      - tmux_error_handler_assign ++ <- investigate!
        - validate_varname - checked
      - display_commands_toggle - only used to display commands, so not a priority
      - tmux_vers_check - checked
  - sort_menu_items
    - generate_menu_items_in_sorted_order
  - verify_menu_runable

- display_menu
  - safe_now
  - ensure_menu_fits_on_screen

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
