# Plan

See if instead of just displaying defaults as (x) , displaying current binding as [x] is possible

## vers_check cashing

not     - 2.220 0.272 0.210 0.238
y grep  - 0.409 0.204 0.225 0.239
        - 0.386 0.212 0.217 0.247
        - 0.381 0.247 0.220 0.215
y case  - 0.299 0.236 0.235 0.199
        - 0.254 0.198 0.219 0.240

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
