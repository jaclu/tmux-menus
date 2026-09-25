# TODO

## plugin init

remove current param cache before reading it to avoid getting polluted by obsoleted settings

## Potential new items

- Client
  - Detach other clients:
  - list connected clients
  - Detach this client
    tmux detach-client
  - Detach other clients
    tmux detach-client -a
  - Detach all other clients from current session
    tmux detach-client -a -s "$(tmux display-message -p '#{session_name}')"
  - Switch session

- Display commands - if no binds, say so and go to default

- Window
  <!-- - list connected clients ?
  - Detach other clients ?
  - Detach from this ?updated -->
  - Scroll window larger than screen
    prefix S-Arrow

## Inspect if this works as intended

has_lf_not_at_end

## Window width for Display Commands

In Display command - filter out menu reload stuff
if line is cut off with > the - for disabling the line does not seem to work

unless enabled via tmux.conf

and if no log_file - short circuit safe_now to always return 0, or perhaps
a counter if 0 causes issues

choose-tree - 1.8 - not usable in 1.7

- flags
  - -Z 2.7

## Floating pane menu

implement checks that move and resize doesn't go outside window borders.

## Revert to default

an empty setting like "" / '' should revert to default

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

## Benchmarking 26-09-19

### Pad5 sysload < 2.5

```tmux
@menus_log_file /home/jaclu/tmp/tmux-menus-t2.log
@menus_show_key_hints No
@menus_trigger Space
@menus_use_hint_overlays No
@menus_use_timers Yes
@menus_validate_cache No
@use_bind_key_notes_in_plugins Yes
```

#### Alpine 3.6

```text
Nocache
- main  0.78 0.58 0.62 0.54
- panes 0.78 1.02 1.00 0.92

Cache
- main  0.20 0.19 0.19 0.17 0.19
- panes 0.24 0.24 0.24 0.33 0.36
```

#### asdf 3.6

```text
Nocache
- main  0.59 0.67 0.63 0.59
- panes 0.95 0.97 0.77 1.09

Cache
- main  0.20 0.19 0.21 0.31
- panes 0.40 0.24 0.24 0.23
```

#### asdf 3.8-ac

```text
Nocache
- main  1.00 0.89 0.91 0.87
- panes 1.18 1.29 1.38 1.48

Cache
- main  0.61 0.74 0.49 0.59
- panes 1.19 0.77 0.70 0.54
```
