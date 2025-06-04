# Modifications

Each menu is a standalone script, making it easy to edit. Once saved,
the updated content will be displayed the next time the menu is triggered.

**Fast development with minimal hassle!**

If an edited menu fails to load, you can run it directly from the command
line to check for syntax errors:

```bash
./items/sessions.sh
```

This will immediately execute the menu and display any errors in the terminal.

If `@menus_log_file` is set—either in the tmux configuration or hardcoded in
`scripts/helpers_minimal.sh` (around line 491, look for assignment of cfg_log_file)
logging can be used within menus:

```bash
log_it "foo is now [$foo]"
```

If monitoring a log file in a separate terminal is impractical,
you can set the log file to `/dev/stderr` to make `log_it` behave like `echo`.

Using `/dev/stderr` instead of `/dev/stdout` prevents unintended errors if
`log_it` is called during string assignments.

## Menu building

Each item consists of at least two parameters

- min tmux version for this item, set to 0.0 if assumed to always work
- Type of menu item, see below
- Additional parameters depending on the item type

Item types and their parameters

- M - Open another menu
  - shortcut for this item, or "" if none wanted
  - label
  - menu script
- C - run tmux Command
  - shortcut for this item, or "" if none wanted
  - label
  - tmux command
- E - run External command
  - shortcut for this item, or "" if none wanted
  - label
  - external command
- T - Display text line
  - text to display. Any initial "-" (making it unselectable in tmux menus)
    will be skipped if whiptail is used, since a leading "-" would cause it to crash.
- S - Separator/Spacer line line
  - no parameters

### Sample script

```shell
#!/bin/sh

static_content() {
  # Be aware:
  #   'set -- \' creates a new set of parameters for menu_generate_part
  #   'set -- "$@" \' should be used when appending parameters

  set -- \
    0.0 M Left "Back to Main menu  $nav_home" "main.sh" \
    0.0 S \
    0.0 T "Example of a line extending action" \
    2.0 C "r" "Rename this session" "command-prompt -I '#S' \
        'rename-session -- \"%%\"'" \
    0.0 S \
    0.0 T "Example of action reloading the menu" \
    1.8 C "z" "Zoom pane toggle" "resize-pane -Z $runshell_reload_mnu"

  menu_generate_part 1 "$@"
}

menu_name="Simple Test"

#  Full path to tmux-menux plugin
#  This script is assumed to have been placed in the items folder of
#  this repo, if not, D_TM_BASE_PATH needs to bechanged the path of the repo
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh


```

### Complex param building for menu items

If whilst building the dialog, a break is needed, to check somecondition, just
pause the `set --` param assignments, do the check and then resume param assignment
using `set -- "$@"`

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
