# Plan

## Release check

up to excluding Missing keys

## Whiptail menu reload

Disabled for now should try to solve it

## external_tools/dropbox.sh

toggle not working

## check env needs

- currencies
- external_tools/spotify

## hepp

move f_current_script to helpers-full

## support scripts needing all helpers

should source scripts/helpers_all.sh

## Caching tweak

During cache creation, of no dynamic cache was generated, ensure only one
cache segment exists, to cut down on reading the cache

## Changing menu handler

Noticed on: iSH MacOs Linux

When switching from normal menus to whiptail using `export TMUX_MENU_HANDLER=1`
Despite menus.tmux giving this output

```log
[11:29:41] whiptail is selected due to TMUX_MENU_HANDLER=1
[11:29:41] ==> [helpers] Using Alternate dialog handler: whiptail
```

- param cache isn't replaced
- clear cache/items, to ensure incorrect cache isn't used

## Pane titles

Add items, enable/disable show pane titles

## Show defaults

See if instead of just displaying defaults as (x) , displaying current
binding as [x] is possible

Seems hard to implement, left as a long term goal
