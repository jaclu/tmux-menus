# tmux-menus

Popup menus to help with managing your environment.

## Purpose

Not only meant for beginers, I use it myself regularly for tasks I can't be bothered to learn by heart.<br>
I have also tried to add some more general items, that might be helpful to others.<br>
It's fairly easy to add/remove items to fit your specific needs.

## Usage

Once installed, hit the trigger to get the main menu to popup.
Default is ``` <prefix> \ ``` see Settings below for how to change it.

## Screenshots

![main](/screenshots/main.png)
![help](/screenshots/help.png)
![panes](/screenshots/panes.png)
![winws](/screenshots/windows.png)
![sessions](/screenshots/sessions.png)
![winws](/screenshots/advanced.png)

## Compatability

| Version| Notice |
| -------| ------------- |
| 3.2 -   | Fully compatible  |
| 3.0 - 3.1c | Can show the menus, centering not supported, will be displayed top left. <br>Additionally some actions might not work depending on version. <br> There should be a notification message about "unknown command" in such casses. |


## Installation

### Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

Add plugin to the list of TPM plugins in `.tmux.conf`:

```tmux
set -g @plugin 'jaclu/tmux-menus'
```

Hit `<prefix> + I` to fetch the plugin and source it.

### Manual Installation

Clone the repo:

```shell
git clone https://github.com/jaclu/tmux-menus.git ~/clone/path
```

Add this line to the bottom of `.tmux.conf`:

```tmux
run-shell ~/clone/path/menus.tmux
```

From the terminal, reload TMUX environment:

```shell
tmux source-file ~/.tmux.conf
```

## Settings

Default trigger key is ``` <prefix> \ ```

If you want to change it you can assign a value to  @menus_trigger

Sample
```tmux
set -g @menus_trigger 'b'
```

If you want use special chars like \ ^ $ & etc, you must prefix them with \

The default binding would be given as ``` '\\' ```


## Modifications

If you want to experiment with changing the menus, I would recomend to first clone/copy this repo to a different location on your system.

Then by just running ./menus.tmux in the new location, your trigger key will bind to this alternate menu set. 
So next time you trigger the menus you will get this in-development menu tree.

Each menu is run as a script, so you can edit a menu script and once it is saved, the new content will be displayed next time you trigger that menu.

So rapid development with minimal fuzz!

If you are struggeling with a menu edit, I would suggest to just run that menu item in a pane of the tmux session your working on 

``` ./items/sessions.sh ```

this will directly trigger that menu and display any syntax errors. I often add lines like

``` echo "foo is now [$foo]" >> /tmp/menus-dbg.log ```

to be able to inspect stuff, if something seems not to be working.

When done, deploy by copy/commit your changes to the default location, this will be used from now on.

If you want to go back to your installed version for now, either reload configs, or run menus.tmux in your normal tmux-menus dir, regardless the installed version will be activated next time you start tmux in any case.


## License

[MIT](LICENSE.md)
