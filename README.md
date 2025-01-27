# Tmux-Menus

<img width="250" alt="main"
src="https://github.com/user-attachments/assets/c614dcc3-af19-4068-9b92-7bf37d3637d9" />
<img width="250" alt="main-styled"
src="https://github.com/user-attachments/assets/b735e489-8b98-4bd5-a4b2-d9b81e3c5679" />

## Summary

Popup menus to help with managing the tmux environment. If so desired,
[styling](Styling.md) can be used.

Not too hard to adapt to fit your needs. Items that some
might find slightly redundant are included, easier to remove excess for more
experienced users, then add more for newbies.

<details>
<summary>Recent Changes</summary>
<br>

## Recent Changes

- Display available keys in an key-hints overlay when selecting an action displaying
  a tmux choose dialog.<br>
  Can be disabled with `set -g @menus_use_hint_overlays No`
- Added help for selection of paste buffers
- Split handling of external dialogs into two scripts, to improve job control
- Added support for dialog as external menu handler

</details>
<details>
<summary>Purpose</summary>
<br>

## Purpose

Tmux provides a few basic popup menus by default, but they're quite limited and
difficult to extend due to their complex, mouse-based one-liner implementations.
A more integrated, user-friendly approach with better navigation and flexibility
seemed like the right solution.

Not solely meant for beginners, I use it myself all the time:

- When connecting using terminals without much support for Meta or Ctrl,
  this gives access to all the actions that aren't available with the
  regular shortcuts. For instance, when running the built in Terminal on
  MacOS the console keyboard is pretty limited.
- Tasks that would need external scripts to avoid hard-to-read
  complex bind one-liners, such as killing the current session without getting
  disconnected.
- When direct typing would be much longer.
  Example: Kill the server directly with 12 keys:
  `<prefix> : kill-ser <tab> <enter>`
  with the menus 5 keys: `<prefix> \ A x y`
- Actions used to seldom to be remembered as shortcuts.

</details>
<details>
<summary>Usage</summary>
<br>

## Usage

Once installed, hit the trigger to get the main menu to pop up.
The default is `<prefix> \` see Configuration below for how to change it.

</details>
<details>
<summary>Screenshots of some menus</summary>
<br>

## Screenshots

The white one is generated with whiptail, as can be seen whiptail menus use a lot
more screen real estate, however if they don't fit they can be scrollable unlike
the tmux menus. The rest are generated by the tmux built-in `display-menu`

<img width="250" alt="help"
src="https://github.com/user-attachments/assets/60e5ef86-d3b8-43ad-9022-ec1f758167f0" />
<img width="265" alt="Image"
src="https://github.com/user-attachments/assets/8066682b-df60-4840-8f05-cfb2dd3b733c" />
<img width="223" alt="Image"
src="https://github.com/user-attachments/assets/43265acd-09ed-4502-a263-614ecf4fb407" />
<img width="300" alt="paste-buffers"
src="https://github.com/user-attachments/assets/1f54f3ee-ed81-4feb-8192-6f1b89cd5ba9" />
<img width="332" alt="paste-buffers-wt"
src="https://github.com/user-attachments/assets/15650cf5-e2b4-4d0e-ac73-e8b14503bc1f" />

</details>
<details>
<summary>Dependencies & Compatibility</summary>

## Dependencies & Compatibility

| Version    | Notice                                                                                                                             |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| 3.4        | Styling can be used.                                                                                                               |
| 3.2        | Menu location fully available.                                                                                                     |
| 3.0 - 3.1c | Menu centering is not supported, it's displayed top left if C is selected.                                                         |
| < 3.0      | Needs `whiptail` or `dialog` (see below). Menu location and styling settings are ignored.                                          |
| 1.8        | tpm is not available, so the plugin needs to be initialized by running [path to tmux-menus]/menus.tmux directly from the conf file |

The above table covers compatibility for the general tool. Some menu items
has a min tmux version set, if the running tmux doesn't match this,
that item will be skipped. If it turns out that incorrect limits have been set
on some feature, please let me know!

</details>
<details>
<summary>Installing</summary>

## Via TPM (recommended)

The easiest way to install `tmux-menus` is via the [Tmux Plugin
Manager](https://github.com/tmux-plugins/tpm).

1. Add plugin to the list of TPM plugins in `.tmux.conf`:

   ```tmux
   set -g @plugin 'jaclu/tmux-menus'
   ```

2. Hit `<prefix> + I` to install the plugin and activate it. The plugin should now
   be usable.

## Manual Installation

1. Clone the repository

   ```sh
   git clone https://github.com/jaclu/tmux-menus ~/clone/path
   ```

2. Add this line to the bottom of `.tmux.conf`

   ```tmux
   run-shell ~/clone/path/menus.tmux
   ```

3. Reload the `tmux` environment

   ```sh
   # type this inside tmux
   $ tmux source-file ~/.tmux.conf
   ```

The plugin should now be activated.

</details>
<details>
<summary>whiptail / dialog</summary>
<br>

## whiptail / dialog - alternate tools for displaying menus

For tmux < 3.0 the tmux feature`display-menu` is not available.

If found `whiptail` or `dialog` will be used to display menus.

The preferred option is whiptail, but if not found dialog will be used instead.
If neither is available, this plugin will abort displaying an error message.

Since these are full-screen apps, when either is used, the current (if any)
task is suspended, dialogs are run, and when done the suspended task is reactivated.

The menu system works the same using external menu handlers, however the menu
shortcuts are not as convenient, since they do not differentiate between upper
and lower case letters,
and does not at all support special keys like 'Left' or 'Home'

To use external dialog handling on modern tmuxes set this env variable:

- for `whiptail` use `export TMUX_MENU_HANDLER=1`
- for `dialog` use `export TMUX_MENU_HANDLER=2`

In most cases whiptail is installed by default on Linux distros. If not, install
it using the package manager.
One gotcha is that in the Red Hat universe the package is not called whiptail,
the package containing whiptail is called `newt`.

MacOS does not come with whiptail, but it is available in the Homebrew package `newt`.

</details>
<details>
<summary>Configuration</summary>

## Configuration

### Display menus

The default trigger is `<prefix> \` The trigger is configured like this:

```tmux
set -g @menus_trigger F12
```

Please note that non-standard keys, like the default backslash need to
be prefixed with a `\` like `\\` in order not to confuse tmux.

### Display without using prefix

In order to trigger menus without first hitting `<prefix>`

```tmux
set -g @menus_without_prefix Yes
```

This param can be either Yes/true or No/false (the default)

### Menu location

The default locations are: `C` for tmux >= 3.2 `P` otherwise. If whiptail/dialog is used,
menu location is ignored

```tmux
set -g @menus_location_x W
set -g @menus_location_y S
```

For all location options see the tmux man page, search for `display-menu`.
The basic options are:

| Value | Flag | Meaning                                        |
| ----- | ---- | ---------------------------------------------- |
| C     | Both | The centre of the terminal (tmux 3.2 or newer) |
| R     | -x   | The right side of the terminal                 |
| P     | Both | The bottom left of the pane                    |
| M     | Both | The mouse position                             |
| W     | Both | The window position on the status line         |
| S     | -y   | The line above or below the status line        |

### Disable caching

By default menu items are cached, set this to `No` to disable all caching.

```tmux
set -g @menus_use_cache No
```

To be more precise, items listed inside `static_content()` are cached.
Some items need to be freshly generated each time a menu is displayed,
those items are defines in `dynamic_content()` see
[scripts/pane_move.sh](items/pane_move.sh) for an example of this. In that case,
"Swap current pane with marked" is only displayed if there is a marked pane.

The plugin remembers what tmux version was used last time.
If another version is detected as the plugin is initialized, the entire
cache is dropped, so that the right version dependent items can be
selected as the cache is re-populated.
Same if a menu script is changed, if the script is newer than the cache,
that cache item is regenerated.

### Use Hint Overlays

Some menu items will display tmux dialogs, where each have their own rather complex
set of special key bindings - choose-buffer, choose-client, choose-tree and customize-mode

When entering such a dialog, per default an overlay will first be presented lisitng
the keys available for that dialog, if it fits on screen.

Use this setting to disable the overlay feature.

```tmux
set -g @menus_use_hint_overlays No
```

This param can be either Yes/true (the default) or No/false

If `@menus_use_hint_overlays` is enabled, there is a support option
`@menus_show_key_hints` that also can be toggled. If `@menus_use_hint_overlays`
is disabled, `@menus_show_key_hints` is ignored.

#### Show Key Hints

Related to `@menus_use_hint_overlays` Since those key-listings tend to be rather long
they might not fit on screen, and thus be silently skipped.
Enabling this will offer an extra option `Key Hints` on each menu featuring an
alternative that will display such a dialog, and mentioning which item on that
menu it is related to.

This Key Hint will display the dialog the normal way, giving a warning if the
screen is to small, mentioning required screen size.

It will also serve as a hint as to what menu entries are expected to display an overlay.

```tmux
set -g @menus_show_key_hints Yes
```

This param can be either Yes/true or No/false (the default)

### Using Styling for menus

See [Styling.md](Styling.md)

### Pointer to the config file

```tmux
set -g @menus_config_file '~/.configs/tmux.conf'
```

In the main menu, the tmux config file to be reloaded.
The default location for this is:

1. @menus_config_file - if this is defined in the tmux config file, it will be used.
2. $TMUX_CONF - if this is present in the environment, it will be used.
3. $XDG_CONFIG_HOME/tmux/tmux.conf - if $XDG_CONFIG_HOME is defined.
4. ~/.tmux.conf - Default if none of the above are set.

When a reload is requested, the conf file will be prompted for, defaulting
to the first match above. It can be manually changed.

### Logging

Per default logging is disabled. If this is desired, provide a log file name
like this:

```tmux
set -g @menus_log_file '~/tmp/tmux-menus.log'
```

</details>
<details>
<summary>Screen might be too small</summary>
<br>

## Screen might be too small

tmux does not give any error if a menu doesn't fit the available screen,
it just does not display the menu.

The only hint is that the menu is terminated instantaneously.

Since this test is far from perfect, and some computers are really slow,
the current assumption is that if it was displayed < 0.5 seconds,
it was likely due to screen size.
In that case this error will be displayed on the status-bar:

```tmux
tmux-menus ERROR: Screen might be too small
```

It will also be displayed if the menu is closed right away intentionally
or unintentionally, so there will no doubt sometimes be false positives.
If it doesn't happen the next time the menu is attempted, it can be ignored.

</details>
<details>
<summary>Modifications</summary>
<br>

## Modifications

Each menu is a script, so can eaily be editrf it and once saved,
the new content is displayed the next time that menu is triggered.

Rapid development with minimal fuzz!

If an edited menu fails to be displayed, run that menu from the command line,
something like:

```bash
./items/sessions.sh
```

This directly triggers that menu and displays any syntax errors on the
command line.

If `@menus_log_file` is defined, either in the tmux conf, or hardcoded
in `scripts/helpers.sh` around line 289. Logging can be used in menus:

```bash
log_it "foo is now [$foo]"
```

If having two terminals with one tailing a log file is unpractical,
setting the log file to `/dev/stderr` would essentially make it into `echo`.
Choosing `/dev/stderr` instead of `/dev/stdout` avoids triggering errors if
the `log_it` is called during string assignment.

</details>
<details>
<summary>Menu building</summary>
<br>

## Menu building

Each item consists of at least two params

- min tmux version for this item, set to 0.0 if assumed to always work
- Type of menu item, see below
- Additional params depending on the item type

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
  - no params

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
    1.8 C "z" "Zoom pane toggle" "resize-pane -Z $menu_reload"

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
    1.8 C z "Zoom pane toggle" "resize-pane -Z $menu_reload"

if tmux display-message -p '#{pane_marked_set}' | grep -q '1'; then
    set -- "$@" \
        2.1 C s "Swap current pane with marked" "swap-pane $menu_reload"
fi

set -- "$@" \
    1.7 C p "Swap pane with prev" "swap-pane -U $menu_reload" \
...
```

</details>
<details>
<summary>Contributions</summary>
<br>

## Contributions

Contributions are welcome, and they're appreciated.
Every little bit helps, and credit is always given.

The best way to send feedback is to file an
[issue](https://github.com/jaclu/tmux-menus/issues)

</details>

## Thanks to

- [JuanGarcia345](https://github.com/JuanGarcia345) for suggesting to make
  menu-cache optional.
- [phdoerfler](https://github.com/phdoerfler) for noticing TMUX_BIN was often not set,
  I had it defined in my .tmux.conf, so totally missed such errors, in future testing I
  will make sure not to rely on env variables.
- [giddie](https://github.com/giddie) for suggesting "Re-spawn current pane"
- [wilddog64](https://github.com/wilddog64) for suggesting adding a prefix
  to the curl that probes public IP

## License

[MIT](LICENSE)
