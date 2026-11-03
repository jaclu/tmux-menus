# Modifications

Each menu is a standalone script, making it easy to edit. Once saved,
the updated content will be displayed the next time the menu is triggered,
as long as [Validate Cache](Advanced.md#validate-cache) is enabled,
or [Caching](Advanced.md#caching) is disabled.

If changes don't take effect, running `rm -rf [tmux-menus folder]/cache/menus`
will cause all menus to be regenerated.

During plugin initialization, TMUX_MENUS_LOCATION is set as a global tmux
environment variable, so it can always be used as the location of the plugin.

If an edited menu fails to load, you can run it directly from the command
line to check for syntax errors. Note that the initial panes created at tmux
startup do not have TMUX_MENUS_LOCATION set. The simplest approach is to create
a new pane, where this variable is present, before running menus manually.

```bash
./items/sessions.sh
```

This will immediately execute the menu and display any errors in the terminal.

If [Logging](Advanced.md#logging) is enabled, logging can be used within menus:

```bash
log_it "foo is now [$foo]"
```

If monitoring a log file in a separate terminal is impractical,
the log file can be set to `/dev/stderr` to make `log_it` behave like `echo`.

Using `/dev/stderr` instead of `/dev/stdout` prevents unintended errors if
`log_it` is called during string assignments.

## Menu building

Each item consists of at least two parameters

- min tmux version for this item, set to 0.0 if assumed to always work
- Type of menu item, see below
- Additional parameters depending on the item type

Item types and their parameters:

- M - Open another menu
  - shortcut for this item, or "" if none wanted
  - label - can use styling
  - menu script
- C - Run tmux Command
  - shortcut for this item, or "" if none wanted
  - label - can use styling
  - tmux command
- E - Run External command
  - shortcut for this item, or "" if none wanted
  - label - can use styling
  - external command
- T - Display text line
  - text to display - can use styling
- S - Separator/Spacer line
  - no parameters

### Sample script

```shell
#!/bin/sh

static_content() {
  # Be aware:
  #   'set -- \' creates a new set of parameters for menu_generate_part
  #   'set -- "$@" \' should be used when appending parameters

  set -- \
    0.0 M Home "Main Menu         $nav_home" "$cfg_main_menu" \
    0.0 S \
    0.0 T "Example of a line extending action" \
    2.0 C "r" "Rename this session" "command-prompt -I '#S' 'rename-session -- \"%%\"'" \
    0.0 S \
    0.0 T "Example of action reloading the menu" \
    1.8 C "z" "Zoom pane toggle" "resize-pane -Z $runshell_reload_mnu"

  menu_generate_part 1 "$@"
}

menu_name="Simple Test"

. "$TMUX_MENUS_LOCATION"/scripts/menu_handling.sh

```

### Complex param building for menu items

Each menu contains two main functions: `static_content()` defines items that can be cached,
and `dynamic_content()` defines items that must be generated each time the menu is displayed.

#### String style conditions

For string style items that vary depending on conditions or tmux version, doing the
check before defining the menu is usually more convenient, like:

```shell
if tmux_vers_check 1.7; then
    same_folder="-c '#{pane_current_path}'"
else
    same_folder=""
fi
```

And then simply use this string when creating the relevant menu item part

#### When the condition defines if an entire menu item should be used or not

If a condition must be checked while building the menu, pause the `set --` param
assignments, do the check and then resume param assignment using `set -- "$@"`

Something like this:

```shell
...
    1.8 C z "Zoom pane toggle" "resize-pane -Z $runshell_reload_mnu"

if tmux display-message -p '#{pane_marked_set}' | grep -q '1'; then
    set -- "$@" \
        2.1 C s "Swap current pane with marked" "swap-pane $runshell_reload_mnu"
fi

set -- "$@" \
    1.7 C p "Swap pane with prev" "swap-pane -U $runshell_reload_mnu" \
...
```
