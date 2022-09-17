# Tmux-Menus

Popup menus to help with managing your environment.

Not to hard to adopt to fit your needs. Items that some
might find slightly redundant are included, easier to remove excess for more
experienced users, than to add more for newbies.

## Recent changes

- Extras - added Dropbox. It has been tested to work on Linux.
- Added to Extras/Mullvad VPN - display status
- Changed shortcut to kill session/server from k into x in Advanced and
Sessions, to ensure vi style navigation keys don't select anything
- Extras - Configure other software, supported: Spotify, Mullvad VPN
Further suggestions are welcome.
- Layouts - listing, but not using defaults that aren't usable in popup menus
- Fixed incorrect default in Advanced

## Purpose

Some basic popup menus come as default
(See *Configuration* on how to turn them off)

- `<prefix> <` displays some windows handling options
- `<prefix> >` displays some pane handling options
- Right clicking on pane, status or status left.

Rather lacking and since they're written as hard to read
one-liners, a more integrated approach with navigation and adaptability seemed
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

## Screenshots

![main](https://user-images.githubusercontent.com/5046648/167640620-26b4b7da-e3fc-4270-bdc8-431555744d3b.png)
![Help Summary](https://user-images.githubusercontent.com/5046648/167317979-63219b33-f9c0-4c80-95fc-2c7a9e4edcdb.png)
![Pane](https://user-images.githubusercontent.com/5046648/167306468-a3711e0f-c8b8-4b02-82e2-b464c77d7f92.png)
![Window](https://user-images.githubusercontent.com/5046648/167306488-42df3119-6458-42c7-90a1-382e47c5420c.png)
![Advanced](https://user-images.githubusercontent.com/5046648/172018080-ad23ff4a-57d6-46c5-ab73-deed32b9914e.png)
![Session](https://user-images.githubusercontent.com/5046648/167306514-b02f26a3-5589-4843-8b66-0e4b710c7a20.png)

## Install

### Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

Add plugin to the list of TPM plugins in `.tmux.conf`:

    set -g @plugin 'jaclu/tmux-menus'

Hit prefix + I to fetch the plugin and source it. You should now be able to
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
for tmux and fail to bind any key.

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

### Live config

If you want to be able to dynamically edit menu settings from within menus,
set this

```tmux
set -g @menus_config_overrides 1
```

This param can be either 0 (the default) or 1

configurable items: menu location

### Default menus

To turn off the limited default popup menus, add the following

```tmux
unbind-key -n MouseDown3Pane
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

## Compatibility

<table><tr><th>Version<th>Notice</th></tr>
<tr>
  <td> 3.2 -<td>Fully compatible</td>
</tr>
<tr>
  <td>3.0 ⁠ 3.1c<td>Menu centering not supported, it's displayed top left
  if C is menu location. Some actions might not work depending on version.
  There should be a notification message about "unknown command" in such cases.
</td></tr></table>

## Contributing

Contributions are welcome, and they're appreciated.
Every little bit helps, and credit is always given.

The best way to send feedback is to file an issue at
[issues](https://github.com/jaclu/tmux-menus/issues)

### Thanks to

- [giddie](https://github.com/giddie) for suggesting "Re-spawn current pane"

#### License

[MIT](LICENSE.md)
