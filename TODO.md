# Issues

I have disabled Extras for now, havent had time to rework them to
fit into the dynamic menus notation

## Simple millisecond timing test

true && t_start="$(date +%s.%N)"

if true; then
    t_end="$(date +%s.%N)"
    duration="$(echo "$t_end - $t_start" | bc)"
    # duration=$(($(date +%s.%N) - t_start))
    echo "$duration"
    exit 1
fi
