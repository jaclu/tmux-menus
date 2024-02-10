# Plan

See if instead of just displaying defaults as (x) , displaying current binding as [x] is possible

## Caching menus

reading the pre generated menu items line by line to capture dynamic
content ends up being a lot of processing, negating benefits of caching
instead each dynamic segment splits the cache file.

When processing such a cache read that entire segment into a variable
generate dynamic content into a variable, read next segment, if more
dynamic parts rinse - repeat
once everyting is read in, feed all parts into eval - Should be quick!?!

### General

#### No cache

- cache non dynamic part
- generate dynamic part
- cache other static part
- generate dynamic part
- cache other static part

#### is cached

- if item file newer than cache, 1st drop cache
- grab cache - 1
- generate dynamic
- graab cache -2
- rinse repeat

#### display current stuff

display cached & live parts


### Variables

D_TM_BASE_PATH - base path of tmux-menus
f_cache_file - the cache file currently being processed


## Renames that should happen

current_script -> f_current_script

## Pane titles

Add items, enable/disable show pane titles

## Window - Move - link/unlink

seems buggy, need to investigate

## Simple millisecond timing test

true && t_start="$(date +%s.%N)"

if true; then
    t_end="$(date +%s.%N)"
    duration="$(echo "$t_end - $t_start" | bc)"
    # duration=$(($(date +%s.%N) - t_start))
    echo "$duration"
    exit 1
fi
