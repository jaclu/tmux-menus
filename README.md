# tmux-menus

Popup menus to help with managing your environment.

## Purpose

Not only meant for beginers, I use it myself regularly for tasks I can't be bothered to learn by hart.<br>
I have also tried to add some more general items, that might be helpful to others.<br>
It's fairly easy to add/remove items to fit your specific needs.

## Usage

Once installed, hit the trigger to get the main menu to popup.
Default is ``` <prefix> \ ``` see Settings below for how to change it.


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

## License

[MIT](LICENSE.md)
