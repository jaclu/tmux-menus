# Plan

just reworked the menu generation, will monitor bugs for now, no new
features planned ATM.

## display whiptail dialog via shortcut

Investigate if a combination of this could work

- send-keys C-z
- running the dialog(-s) in active pane
- checking if jobs displays anything and if so do a fg 

This wont be foolproof, there are a few cases where Ctrl-Z is not supported. First check if it works at all

## Simple millisecond timing test

true && t_start="$(date +%s.%N)"

if true; then
    t_end="$(date +%s.%N)"
    duration="$(echo "$t_end - $t_start" | bc)"
    # duration=$(($(date +%s.%N) - t_start))
    echo "$duration"
    exit 1
fi

