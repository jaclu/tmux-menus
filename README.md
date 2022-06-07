# tmux-menus

Popup menus to help with managing your environment.

Simple to modify to fit your needs. I have included several items that some might find slightly redundant, since it is easier to remove excess for more experienced users, than it is to add more for newbies.

#### Recent changes

- Layouts - listing, but not using defaults that are not usable in popup menus
- Fixed incorrect default in Advanced
- New feature, Advanced - Plugin Configuration, available if @menus_config_overrides is set to "1"
- Moved "List all key bindings" to Advanced Options
- To make it more phone friendly, it now checks for window size, displaying size requirement for the menu if it does not fit. Menus just don't display if the screen is to small.

## Purpose

There are some very basic popups per default (See *Configuration* on how to disable them)

-   `<prefix> <` displays some windows handling options
-   `<prefix> >` displays some pane handling options
-   Right clicking on pane, status or status left.

I find them rather lacking and since they are written as hard to read one-liners, I preferred a more integrated approach with navigation and simple adaptability, also covering more than just panes and windows.

Not only meant for beginners, I use it myself all the time:

- When connecting using terminals without much support for Meta or Ctrl, then this gives me access to all the stuff that is not available with my normal shortcuts. For instance when running iSH the console keyboard is very limitd.
- Tasks that would need external scripts in order to avoid hard to read complex bind one-liners, such as kill curent session, without getting disconnected.
- When direct typing would be much longer.<br> Example: Kill the server directly is min 12 keys: `<prefix> : kill-ser <tab> <enter>` <br> with the menus it is 5 keys: `<prefix> \ A k y ` <br>
- Things I use to seldom to remember as shortcuts.

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

Hit prefix + I to fetch the plugin and source it. You should now be able to use the plugin.

### Manual Installation

Clone the repository:

    $ git clone https://github.com/jaclu/tmux-menus.git ~/clone/path

Add this line to the bottom of `.tmux.conf`:

    run-shell ~/clone/path/menus.tmux

Reload TMUX environment with `tmux source-file ~/.tmux.conf`. You should now be able to use the plugin.

## Configuration

### Changing the key-bindings for this plugin

The default trigger is `<prefix> \`. Trigger is selected like this:

```
set -g @menus_trigger 'F9'
```

Please note that special keys, like the default backslash needs to be noted in a specific way in order not to confuse tmux.
Either `'\'` or without quotes as `\\`. Quoting `'\\'` will not make sense for tmux and fail to bind any key!

If you want to trigger menus without first hitting `<prefix>`

```
set -g @menus_without_prefix 1
```

This param can be either 0 (the default) or 1


### Menu location

Default location is: P, since it is compatible with older tmux versions

Locations can be one of:

-   W - By the current window name in the status line
-   P - Lower left of current pane
-   C - Centered in window (tmux 3.2 and up)
-   M - Mouse position (does not seem to work as intended...)
-   R - Right edge of terminal (Only for x)
-   S - Next to status line (Only for y)
-   Number - In window coordinates 0,0 is top left. To make it even more confusing, the coordinate defines lower left of the menus placement...

```tmux
set -g @menus_location_x 'C'
set -g @menus_location_y 'C'
```

### Live config

If you want to be able to dynamically edit menu settings from within menus, set this

```
set -g @menus_config_overrides 1
```

This param can be either 0 (the default) or 1

Currently only menu location can be set.

### Default menus

To disable the fairly limited default popup menus, add the following
```
unbind-key -n MouseDown3Pane
unbind-key -n MouseDown3Status
unbind-key -n MouseDown3StatusLeft
unbind-key <
unbind-key >
```

## Indication when window is in synchronized panes mode

Not directly related to this plugin, but since it does have an option to trigger sync mode, and having it on unintendedly can really ruin your day, this might be helpful. You can add this snippet to your status bar to indicate sync mode very clearly, so that you hopefully never leave it turned on when not intended.

```
#[reverse,blink]#{?pane_synchronized,*** PANES SYNCED! ***,}#[default]
```

## Modifications

If you want to experiment with changing the menus, I would recommend to first clone/copy this repository to a different location on your system.

Then by just running `~/path/to/alternate-tmux-menus/menus.tmux`, your trigger key will bind to this alternate menu set.
So next time you trigger the menus you will get this in-development menu tree.

Each menu is run as a script, so you can edit a menu script and once it is saved, the new content will be displayed next time you trigger that menu.

So rapid development with minimal fuzz!

If you are struggling with a menu edit, I would suggest to just run that menu item in a pane of the tmux session your working on, something like

```
./items/sessions.sh
```

This will directly trigger that menu and display any syntax errors on the command line.

In `scripts/utils.sh` there is a function log_it, and a variable log_file. If log_file is defined, any call to log_it will be printed there. If it is not defined, nothing will happen. So log_it lines can be left in the code.

If you are triggering a menu from the command line, you can use direct echo, but then you need to remove it before deploying, since tmux will see any script output as an potential error and display it in a scroll back buffer.<br>
If tailing a log file is unpractical, a more scaleable way to achieve the same result as echo would be to set `log_file='/dev/stdout'`

To trigger log output, just add lines like:

```
log_it "foo is now [$foo]"
```

When done, first unset log_file, then copy or commit your changes to the default location, this will be used from now on.

If you want to go back to your installed version for now, either reload configs, or run `~/.tmux/plugins/tmux-menus/menus.tmux` to rebind those menus to the trigger. Regardless the installed version will be activated next time you start tmux automatically.

## Compatibility

| Version    | Notice
| - | - | 
| 3.2 -      | Fully compatible
| 3.0 - 3.1c | Menu centering not supported, will be displayed top left if C is used as menu location. <br>Additionally some actions might not work depending on version. <br> There should be a notification message about "unknown command" in such cases.

## Contributing

Contributions are welcome, and they are greatly appreciated! Every little bit helps, and credit will always be given.

The best way to send feedback is to file an issue at https://github.com/jaclu/tmux-menus/issues

### Special thanks to
- [giddie](https://github.com/giddie) for contributing "Respawn current pane"

##### License

[MIT](LICENSE.md)
