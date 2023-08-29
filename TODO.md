# Plan

just reworked the menu generation, will monitor bugs for now, no new
features planned ATM.

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
