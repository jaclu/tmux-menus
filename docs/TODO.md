# Plan

See if instead of just displaying defaults as (x) , displaying current
binding as [x] is possible

## no hints

Add option to not show hints when displaying tmux dialogs

## Pane titles

Add items, enable/disable show pane titles

## Devel or rc-candidate tmux

`scripts/utils/tmux.sh:tmux_get_vers()`
Should filter out any `devel-` prefixes and `-rcX` suffixes

Until then hardcode it using something like: `echo "3.4"`
if the installed version of tmux is devel-3.4
