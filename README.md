# Tmux-Menus

Popup menus to help with managing your environment.

Can use whiptail/dialog as alternate menu system, default alternate
dialog env is whiptail

Not to hard to adopt to fit your needs. Items that some
might find slightly redundant are included, easier to remove excess for more
experienced users, than to add more for newbies.

## Recent changes

- Total rework, now the menus are generated dynamically, both for tmux
and whiptail, added version limits to actions. Using whiptail the
menus can be used on all older versions of tmux.
- Added Extras - iSH AOK FS, corrected main help text and some menu min sizes
- Main menu, toggle status Line - new feature
- Main menu, Public IP - It is simply echoed in the current pane, so that there is plenty of time to read and/or copy it.
Just hit Escape to get pane to resume normal operation.

## Purpose

Some basic popup menus come as default
(See *Configuration* on how to turn them off)

- `<prefix> <` displays some windows handling options
- `<prefix> >` displays some pane handling options
- Right click on pane, ALT-right click on pane, status or status left.

Rather lacking and since they're written as hard to read one-liners,
a more integrated approach with navigation and adaptability seemed
the way to go, also covering more than panes and windows.

Not solely meant for beginners, use it myself all the time:

- When connecting using terminals without much support for Meta or Ctrl,
then this gives access to all the actions that aren't available with the
normal shortcuts. For instance when running iSH the console keyboard is
limited.
- Tasks that would need external scripts to avoid hard to read
complex bind one-liners, such as kill current session, without getting
disconnected.
- When direct typing would be much longer.
Example: Kill the server directly is min 12 keys:
`<prefix> : kill-ser <tab> <enter>`
with the menus 5 keys: `<prefix> \ A x y`
- Actions used to seldom to remember as shortcuts.

## Usage

Once installed, hit the trigger to get the main menu to popup.
Default is `<prefix> \` see Configuration below for how to change it.

## Screenshots of some menus

![main](https://user-images.githubusercontent.com/5046648/220794673-6504f675-0b89-41a6-9fa9-16387dada883.png)
![Pane](https://user-images.githubusercontent.com/5046648/200143811-d4e3b254-310e-4207-82b6-a7bd527fcb47.png)
![Window](https://user-images.githubusercontent.com/5046648/200143848-eb7c0c3e-837c-4393-b761-d8424eaa782e.png)
![Advanced](https://user-images.githubusercontent.com/5046648/200143879-4973d4d2-2c74-47a2-9110-d87b5765707a.png)
![Session](https://user-images.githubusercontent.com/5046648/200143930-e27f063f-c054-47d5-9640-502f4127cb14.png)
![Help Summary](https://user-images.githubusercontent.com/5046648/200149023-619deff0-8d66-45e2-be3e-a6def82e9fbc.png)

## whiptail

These menus can also be displayed using whiptail, be aware that the
whiptail menus can't be triggered by the shortcut. When run via "run-shell"
It complains about running in a non-interactive shell. It might be
possible to find a work-arround, however I havent figured that out.

So using whiptail, it can't really be considered a traditional tmux plugin,
you have to launch it manually or by some other means.
But once started, the menu system works the same using whiptail, the
menu shortcuts are not as effective, since whiptail does not differentiate
between upper and lower case letters, and does not at all support special
keys like 'Left' or 'Home'

If tmux is < 3.0 whiptail will automatically be used.
If you want to use whiptail on modern tmuxes set this env variable: `export
FORCE_ALT_DIALOG=1`

## Compatibility
| Version | Notice
| - | - |
3.2 | Fully compatible
3.0 - 3.1c | Menu centering not supported, it's displayed top left if C is menu location.
1.8 - 3.0 | Only available using whiptail

## Installation

### Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

Add plugin to the list of TPM plugins in `.tmux.conf`:

```tmux
set -g @plugin 'jaclu/tmux-menus'
```

Hit `<prefix> + I` to install the plugin and activate it. You should now be able to
use the plugin.

### Manual installation

Clone the repository:

```bash
git clone https://github.com/jaclu/tmux-menus.git ~/clone/path
```

Add this line to the bottom of `.tmux.conf`:

```tmux
run-shell ~/clone/path/menus.tmux
```

Reload TMUX environment with `tmux source-file ~/.tmux.conf`.
You should now be able to use the plugin.

## Configuration

### Changing the key-bindings for this plugin

The default trigger is `<prefix> \`. Trigger is selected like this:

```tmux
set -g @menus_trigger 'F9'
```

Please note that non standard keys, like the default backslash needs to be noted
in a specific way in order not to confuse tmux.
Either `'\'` or without quotes as `\\`. Quoting `'\\'` won't make sense
for tmux and fail to bind the key.

If you want to trigger menus without first hitting `<prefix>`

```tmux
set -g @menus_without_prefix 1
```

This param can be either 0 (the default) or 1

### Menu location

Default location is: P, compatible with older tmux versions

Locations can be one of:

- W - By the current window name in the status line
- P - Lower left of current pane
- C - Centered in window (tmux 3.2 and up)
- M - Mouse position (doesn't seem to work as intended…)
- R - Right edge of terminal (x)
- S - Next to status line (y)
- Number - In window coordinates 0,0 is top left. To make it even more
confusing, the coordinate defines lower left of the menus placement…

```tmux
set -g @menus_location_x 'C'
set -g @menus_location_y 'C'
```

### Pointer to config file

In the main menu, you can request the config file to be reloaded.
The defaults for this is:

 1. TMUX_CONF - if this is pressent in the environment, it will be used.
 2. @menus_config_file - if this is defined in the config file, it will be used.
 3. ~/.tmux.conf - Default if non of the above are set

When a reload is requested, the default will be printed, and used if
not manually changed.

### Live config (disabled for now)

If you want to be able to dynamically edit menu settings from within menus,
set this

```tmux
set -g @menus_config_overrides 1
```

This param can be either 0 (the default) or 1

configurable items: menu location

### Default menus

To disable the rather limited default popup menus, add the following

```tmux
unbind-key -n MouseDown3Pane
unbind-key -n M-MouseDown3Pane
unbind-key -n MouseDown3Status
unbind-key -n MouseDown3StatusLeft
unbind-key <
unbind-key >
```

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

If you want to experiment with changing the menus,
first clone/copy this repository to a different location on your system.

Then by running `~/path/to/alternate-tmux-menus/menus.tmux`, your
trigger key binds to this alternate menu set.
Next time you trigger the menus, this in-development menu tree is used.

Each menu is a script, so you can edit a menu script and once saved,
the new content is displayed next time you trigger that menu.

Rapid development with minimal fuzz.

If you are struggling with a menu edit, run that menu item in a pane
of the tmux session your working on, something like

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
script output as an potential error and display it in a scroll back buffer.
If tailing a log file is unpractical, a more scalable way to achieve the
same result as echo would be to set `log_file='/dev/stdout'`

To trigger log output, add lines like:

```bash
log_it "foo is now [$foo]"
```

When done, first unset log_file, then copy or commit your changes to the
default location, this is used from now on.

If you want to go back to your installed version for now, either reload
configs, or run `~/.tmux/plugins/tmux-menus/menus.tmux` to rebind those
menus to the trigger. Regardless the installed version is activated
next time you start tmux automatically.

## Menu building

Each item consists of at least two params

- min tmux version for this item, set to 0.0 if assumed to allways work
- Type of menu item, see below
- Additional params depending on item type

Item types and their parameters

- M - Open another menu
  - shortcut for this item, or "" if none wanted
  - label for menu
  - menu script
- C - run tmux Command
  - shortcut for this item, or "" if none wanted
  - label for command
  - tmux command
- E - run External command
  - shortcut for this item, or "" if none wanted
  - label for external command
  - external command
- T - Display text line
  - label to display. Since whiptail is more limited in handling labels,
    any initial "-" (making it unselectable in tmux menus) will be
    replaced by " ", leading "-" causes whiptail to crash.
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
CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/dialog_handling.sh"

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

menu_parse "$@"
```

### Complex param building for menu items

If whilst building the parameters, you need to take a break and check some
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

- [giddie](https://github.com/giddie) for suggesting "Re-spawn current pane"
- [wilddog64](https://github.com/wilddog64) for suggesting adding a prefix
to the curl that probes public IP
#### License

[MIT](LICENSE)
