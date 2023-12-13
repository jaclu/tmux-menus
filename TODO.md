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
