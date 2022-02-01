# tmux-menus

Popup menus to help with managing your environment.

Simple to modify to fit your needs. I have included several items that some might find slightly redundant, since it is easier to remove exess for more experienced users, than it is to add more for newbies.

#### Recent changes

- Added @menus_without_prefix for triggering menus without using `<prefix>`

## Purpose

There are some very basic popups per default<br> 

* ``` <prefix> < ``` displays some windows handling options
* ``` <prefix> > ``` displays some pane handling options

I find them rather lacking and since they are written as hard to read one-liners, I prefered a more integrated aproach with navigation and simple adoptability, also covering more than just panes and windows.

Not only meant for beginers, I use it myself regularly for tasks I can't be bothered to learn by heart, stuff that doesn't have a short-cut or when direct typing would be much longer.<br>
Example: Kill the server directly is min 12 keys: ``` <prefix> : kill-ser <tab> <enter> ``` <br>
with the menus it is 6 keys: ```<prefix> \ a K y ``` <br>
  
I have also tried to add some more general items, that might be helpful to others. It's fairly easy to add/remove items to fit your specific needs.


## Usage

Once installed, hit the trigger to get the main menu to popup.
Default is ``` <prefix> \ ``` see Configuration below for how to change it.


## Screenshots

![main](/screenshots/main.png)
![panes](/screenshots/panes.png)
![wins](/screenshots/windows.png)
![sessions](/screenshots/sessions.png)
![layouts](/screenshots/layouts.png)
![split](/screenshots/split_view.png)
![adv](/screenshots/advanced.png)
![help](/screenshots/help.png)
![wins_help](/screenshots/windows_help.png)
![help_split](/screenshots/help_split.png)


## Install

### Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

Add plugin to the list of TPM plugins in `.tmux.conf`:

    set -g @plugin 'jaclu/tmux-menus'

Hit `prefix + I` to fetch the plugin and source it. That's it!

### Manual Installation

Clone the repo:

    $ git clone https://github.com/jaclu/tmux-menus ~/clone/path

Add this line to the bottom of `.tmux.conf`:

    run-shell ~/clone/path/menus.tmux

Reload TMUX environment with `$ tmux source-file ~/.tmux.conf`, and that's it.

## Configuration

### Changing the key-bindings for this plugin

The default trigger is `<prefix> \`. Trigger is selected like this:
 
```
set -g @menus_trigger 'x'
```

Please not that using special keys, like the default backslash needs to be noted in a specific way in order not to confuse tmux.
Either `'\'` or without quotes as `\\`.  Quoting `'\\'` will not make sense for tmux and fail to bind any key!

If you want to trigger menus without first hitting `<prefix>`

```
set -g @menus_without_prefix 1
```

This param can be either 0 (the default) or 1

  
### Menu location

Default location is: P

Locations can be one of:

 * W - By the current window name in the status line
 * P - Lower left of current pane
 * C - Centered in window (tmux 3.2 and up)
 * M - Mouse position
 * R - Right edge of terminal (Only for x)
 * S - Next to status line (Only for y)
 * Number - In window coordinates 0,0 is top left

```tmux
set -g @menus_location_x 'C'
set -g @menus_location_y 'C'
```


## Indication when window is in synchronized panes mode

Not directly related to this plugin, but since it does have an option to trigger sync mode, and having it on unintendedly can really ruin your day, this might be helpful. If you want to trigger syncronized mode. You can add this snippet to your status bar to indicate sync mode very clearly, so that you hopefully never leave it turned on when not intended.

```
#[reverse,blink]#{?pane_synchronized,*** PANES SYNCED! *** ,}#[default]
```


## Modifications

If you want to experiment with changing the menus, I would recomend to first clone/copy this repo to a different location on your system.

Then by just running ./menus.tmux in the new location, your trigger key will bind to this alternate menu set. 
So next time you trigger the menus you will get this in-development menu tree.

Each menu is run as a script, so you can edit a menu script and once it is saved, the new content will be displayed next time you trigger that menu.

So rapid development with minimal fuzz!

If you are struggeling with a menu edit, I would suggest to just run that menu item in a pane of the tmux session your working on, something like

```
./items/sessions.sh
```
this will directly trigger that menu and display any syntax errors on the command line.

In utils I have a function log_it. If log_file is defined, any log_it will be printed there.

```
log_it "foo is now [$foo]"
```

This can be left in the code once you'r done debugging for later usage. Without log_file being set nothing will printed.

If you are triggering a menu from the command line, you can use direct echo, but then you need to remove them before deploying, since tmux will see any script output as an potential error and display it in a scroll back buffer.

When done, deploy by copy/commit your changes to the default location, this will be used from now on.

If you want to go back to your installed version for now, either reload configs, or run ~/.tmux/plguins/tmux-menus/menus.tmux to rebind those menus to the trigger. Regardless the installed version will be activated next time you start tmux.


## Compatability

| Version| Notice |
| -------| ------------- |
| 3.2 -   | Fully compatible  |
| 3.0 - 3.1c | Menu centering not supported, will be displayed top left if C is used as menu location. <br>Additionally some actions might not work depending on version. <br> There should be a notification message about "unknown command" in such casses. |


## Contributing

Contributions are welcome, and they are greatly appreciated! Every little bit helps, and credit will always be given.

The best way to send feedback is to file an issue at https://github.com/jaclu/tmux-menus/issues


##### License

[MIT](LICENSE.md)
