# Plan

See if instead of just displaying defaults as (x) , displaying current binding as [x] is possible

## Replace script & item folder references

ITEMS_DIR  -> D_TM_ITEMS
SCRIPT_DIR -> D_TM_SCRIPTS

---  set in scripts/utils.sh
D_TM_BASE_PATH
D_TM_SCRIPTS="$D_TM_BASE_PATH"/scripts
D_TM_ITEMS="$D_TM_BASE_PATH"/items


old:

ITEMS_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

extras_dir in extras menus need changing

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
