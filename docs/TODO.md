# Plan

## Release check

- remove branch check for main menu label in dialog_handling:cache_static_content

### WhipTail

- menu_reload is not working, so disabled
- pane resize does nothing

## external_tools/dropbox.sh

toggle not working

## support scripts needing all helpers

should source scripts/helpers_all.sh

## Caching tweak

During cache creation, if no dynamic cache was generated, ensure only one
cache segment exists, to cut down on reading the cache

## Pane titles

Add items, enable/disable show pane titles

## Show defaults

See if instead of just displaying defaults as (x) , displaying current
binding as [x] is possible

Seems hard to implement, left as a long term goal
