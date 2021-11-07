# tmux-menus

Popup menus to help with managing your environment

## Purpose

Not only meant for begginers, I use it myself daily for tasks I use so rarely
that I struggle to remember some of the shortcuts.
I have also tried to add some more general, that I don't need myself,
but might be helpful to others. It's fairly easy to add/remove items to fit your
specific needs.

## Installation

Compatability: tmux version 3.0 or higher

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

## Usage

Once installed hit the current trigger (see Settings below) to get the main menu top popup.


## Settings

Default trigger key is <prefix> \

If you want to change it you can assign a value to  @menus_trigger

Sample

set -g @menus_trigger 'B'

