# Tmux-Menus

Popup menus to help with managing your environment.

For tmux < 3.0 whiptail will be used instead of the tmux feature
`display-menu`.

Not too hard to adapt to fit your needs. Items that some
might find slightly redundant are included, easier to remove excess for more
experienced users, then add more for newbies.

## Recent changes

- ITEMS_DIR & SCRIPT_DIR must be defined before sourcing dialog_handling.sh, updated for all menus
- current_script is correctly defined when script is run from other locations than items/
- pane zoom only offered if more than one pane in window
- Added check that TMUX_BIN has been set
- Added Clear history & screen to panes menu
- whiptail menus can be used via the shortcut
- Now you can pre-define config file, so that you don't have to
type it in every time you choose `Reload configuration file` in case
you are not using `~/.tmux.conf` check section `Pointer to config file`
below for details.

## Purpose

Some basic popup menus come as the default
(See *Configuration* for how to disable them)

- `<prefix> <` displays some Windows handling options
- `<prefix> >` displays some pane handling options
- Right-click on pane, ALT-right click on pane, status or status left.

Rather lacking and since they're written as hard-to-read one-liners,
a more integrated approach with navigation and adaptability seemed
the way to go, also covering more than panes and windows.

Not solely meant for beginners, I use it myself all the time:

- When connecting using terminals without much support for Meta or Ctrl,
this gives access to all the actions that aren't available with the
regular shortcuts. For instance, when running iSH the console keyboard is
pretty limited.
- Tasks that would need external scripts to avoid hard to read
complex bind one-liners, such as kill the current session, without getting
disconnected.
- When direct typing would be much longer.
Example: Kill the server directly is min 12 keys:
`<prefix> : kill-ser <tab> <enter>`
with the menus 5 keys: `<prefix> \ A x y`
- Actions used to seldom to remember as shortcuts.

## Usage

Once installed, hit the trigger to get the main menu to pop up.
The default is `<prefix> \` see Configuration below for how to change it.

## Screenshots of some menus

The grey one is generated with whiptail, the rest by tmux built-in `display-menu`

![main](https://github.com/jaclu/tmux-menus/assets/5046648/5ed4fd3f-25fc-4449-9c8a-6fc27b35fdc1.png)
![Whiptail main](https://github.com/jaclu/tmux-menus/assets/5046648/11ac1c9f-cb19-4dba-a29d-7106ec854fea.png)
![Pane](https://github.com/jaclu/tmux-menus/assets/5046648/68a390be-f4d7-44bc-a9d4-9082ad2c718a.png)
![Window](https://github.com/jaclu/tmux-menus/assets/5046648/34ed1a9b-9ee0-48e9-8b6a-2a28421fd880.png)
![Advanced](https://github.com/jaclu/tmux-menus/assets/5046648/9c9f6198-f78c-4aca-8b67-145caf4adbb2.png)
![Session](https://github.com/jaclu/tmux-menus/assets/5046648/e9cc442f-27c8-458a-88fb-aa558fd08235.png)
![Help Summary](https://github.com/jaclu/tmux-menus/assets/5046648/ccd5da05-a3a6-4f11-910c-855158fefd35.png)

## Compatibility

| Version | Notice
| - | - |
3.2 | Fully compatible
3.0 - 3.1c | Menu centering is not supported, it's displayed top left if C is selected.
1.8 - 3.0 | Only available using Whiptail, menu location setting ignored.

The above table covers compatibility for the general tool. Each item
has a min tmux version set, if the running tmux doesn't match this,
that item will be skipped.

## Installing

### Via TPM (recommended)

The easiest way to install `tmux-menus` is via the [Tmux Plugin
Manager](https://github.com/tmux-plugins/tpm).

1. Add plugin to the list of TPM plugins in `.tmux.conf`:

    ``` tmux
    set -g @plugin 'jaclu/tmux-menus'
    ```

2. Hit `<prefix> + I` to install the plugin and activate it. You should
    now be able to use the plugin.

### Manual Installation

1. Clone the repository

    ``` sh
    git clone https://github.com/jaclu/tmux-menus ~/clone/path
    ```

2. Add this line to the bottom of `.tmux.conf`

    ``` tmux
    run-shell ~/clone/path/menus.tmux
    ```

3. Reload the `tmux` environment

    ``` sh
    # type this inside tmux
    $ tmux source-file ~/.tmux.conf
    ```

You should now be able to use `tmux-menus` immediately.

## Whiptail

These menus can also be displayed using Whiptail, be aware that in order
to run whiptail dialogs via a shortcut, the current (if any) task is
suspended, dialogs are run, and when done the suspended task is
reactivated.

The downside of this is that if there were no current task running in
the active pane, you will see `fg: no current job` being printed when
the dialog is exited. This can be ignored.

The menu system works the same using Whiptail, however the menu
shortcuts are not as convenient, since Whiptail does not differentiate
between upper and lower case letters, and does not at all support
special keys like 'Left' or 'Home'

If tmux is < 3.0 whiptail will automatically be used.
If you want to use Whiptail on modern tmuxes set this env variable:
`export FORCE_WHIPTAIL_MENUS=1`

## Configuration

### Changing the key bindings for this plugin

The default trigger is `<prefix> \`. The trigger is selected like this:

```tmux
set -g @menus_trigger 'F9'
```

Please note that non-standard keys, like the default backslash needs to
be noted in a specific way in order not to confuse tmux.
Either `'\'` or without quotes as `\\`. Quoting `'\\'` won't make sense
for tmux and fail to bind the key.

If you want to trigger menus without first hitting `<prefix>`

```tmux
set -g @menus_without_prefix 1
```

This param can be either 0 (the default) or 1

### Menu location

The default location is: P, compatible with tmux 3.0 and up

Locations can be one of:

- W - By the current window name in the status line
- P - Lower left of the current pane
- C - Centered in the window (tmux 3.2 and up)
- M - Mouse position (doesn't seem to work as intended…)
- R - Right edge of the terminal (x)
- S - Next to the status line (y)
- Number - In pane coordinates 0,0 is the top left. To make it even more
confusing, the coordinate defines the lower left of the placement of the menu…

```tmux
set -g @menus_location_x 'C'
set -g @menus_location_y 'C'
```

### Pointer to the config file

In the main menu, you can request the config file to be reloaded.
The defaults for this are:

 1. $TMUX_CONF - if this is present in the environment, it will be used.
 2. @menus_config_file - if this is defined in the tmux config file,
 it will be used.
 3. ~/.tmux.conf - Default if none of the above are set

When a reload is requested, the default will be printed and used if
not manually changed.

```tmux
set -g @menus_config_file "$XDG_CONFIG_HOME/tmux/tmux.conf"
```

### Default menus

To disable the rather limited default popup menus, you can add the
following

```tmux
unbind-key -n MouseDown3Pane
unbind-key -n M-MouseDown3Pane
unbind-key -n MouseDown3Status
unbind-key -n MouseDown3StatusLeft
unbind-key <
unbind-key >
```

## If a menu doesn't fit the screen

tmux does not give any error if a menu doesn't fit the available
screen. The only hint is that the menu is terminated instantaneously.
For this reason, a menu that is closed right away is assumed to have
failed due to lacking screen real estate,
and then the required min screen size for this dialog is printed.
Starting with tmux 3.2 menus will be shrunk to some extent
to make them fit, so for later versions of tmux you might get away
with a slightly narrower screen than the required size.

## Making synchronized panes stand out

Not directly related to this plugin, but since it does have an option to
trigger sync mode, and having it on unintendedly can ruin your day,
this might be helpful. You can add this snippet to your status bar to
make sync mode stand out, so that you never leave it turned on when
not intended.

```tmux
#[reverse,blink]#{?pane_synchronized,*** PANES SYNCED! ***,}#[default]
```

## Modifications

Each menu is a script, so you can edit a menu script, and once saved,
the new content is displayed the next time you trigger that menu.

Rapid development with minimal fuzz.

If you are struggling with a menu edit, run that menu item in a pane
of the tmux session you are working on, something like

```bash
./items/sessions.sh
```

This directly triggers that menu and displays any syntax errors on the
command line.

In `scripts/utils.sh` there is a function log_it, and a variable log_file.
If log_file is defined, any call to log_it is printed there.
If not defined, nothing happens. log_it lines can be left in the code.

If you are triggering a menu from the command line, you can use direct echo,
but then you need to remove it before deploying, since tmux sees any
script output as a potential error and display it in a scroll-back buffer.
If tailing a log file is unpractical, a more scalable way to achieve the
same result as echo would be to set `log_file='/dev/stdout'`

To trigger log output, add lines like:

```bash
log_it "foo is now [$foo]"
```

## Menu building

Each item consists of at least two params

- min tmux version for this item, set to 0.0 if assumed to always work
- Type of menu item, see below
- Additional params depending on the item type

Item types and their parameters

- M - Open another menu
  - shortcut for this item, or "" if none wanted
  - label for the menu
  - menu script
- C - run tmux Command
  - shortcut for this item, or "" if none wanted
  - label for the command
  - tmux command
- E - run External command
  - shortcut for this item, or "" if none wanted
  - label for external command
  - external command
- T - Display text line
  - label to display. Any initial "-" (making it unselectable in tmux menus) will be skipped if whiptail is used, since leading "-" would cause it to crash.
- S - Separator/Spacer line line
  - no params

### Sample script

```shell
#!/bin/sh

#
#  This script is assumed to have been placed in the items folder of
#  this repo, if not, you will need to change the paths to the support
#  scripts below.
#
ITEMS_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR"/dialog_handling.sh

menu_name="Simple Test"

set -- \
    0.0 M Left "Back to Main menu  <==" "main.sh" \
    0.0 S \
    0.0 T "Example of line extending action" \
    2.0 C "\$" "<P> Rename this session" "command-prompt -I '#S' \
        'rename-session -- \"%%\"'" \
    0.0 S \
    0.0 T "Example of action reloading the menu" \
    1.8 C z "<P> Zoom pane toggle" "resize-pane -Z $menu_reload" \

req_win_width=39
req_win_height=23

menu_parse "$@"
```

### Complex param building for menu items

If whilst building the dialog, you need to take a break and check some
condition, you just pause the `set --` param assignments, do the check
and then resume param assignment using `set -- "$@"`

Something like this:

```shell
...
    1.8 C z "<P> Zoom pane toggle" "resize-pane -Z $menu_reload"

if tmux display-message -p '#{pane_marked_set}' | grep -q '1'; then
    set -- "$@" \
        1.7 C s "Swap current pane with marked" "swap-pane $menu_reload"
fi

set -- "$@" \
    1.7 C "{" "<P> Swap pane with prev" "swap-pane -U $menu_reload" \
...
```

## Contributing

Contributions are welcome, and they're appreciated.
Every little bit helps, and credit is always given.

The best way to send feedback is to file an [issue](https://github.com/jaclu/tmux-menus/issues)

### Thanks to

- [phdoerfler](https://github.com/phdoerfler) for noticing TMUX_BIN was often not set,
I had it defined in my .tmux.conf, so totally missed such errors, in future testing I
will make sure not to rely on env variables.
- [giddie](https://github.com/giddie) for suggesting "Re-spawn current pane"
- [wilddog64](https://github.com/wilddog64) for suggesting adding a prefix
to the curl that probes public IP

#### License

[MIT](LICENSE)
