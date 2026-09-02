# TODO

## Feature availability

choose-tree - 1.8 - not usable in 1.7

- flags
  - -Z 2.7

## Floating pane menu

implement checks that move and resize doesn't go outside window borders.

## Revert to default

an empty setting like "" / '' should revert to default

## vscode faking to run inside t2

```bash
export TMUX=/private/tmp/tmux-501/501-serv2,39012,0
export TMUX_BIN=/Users/jaclu/git_repos/others/tmux/tmux
export TMUX_OUTER=/private/tmp/tmux-501/501-default,64195,0

# Is this needed?
export TMUX_PLUGIN_MANAGER_PATH=/Users/jaclu/t2/tmux/plugins/
```

## @menus_border_type might be obsoleted

- 3.4
  menu-style
  menu-selected-style [display-menu -H]
  menu-border-style
  menu-border-lines

### works

set -g @menus_border_type 'rounded'

ends up as: -b rounded

### no effect

set -g @menus_simple_style_selected 'rounded'

ends up as -H -rounded

### obsoleted in tmux 3.4 by

$TMUX_BIN set-option menu-border-lines rounded
