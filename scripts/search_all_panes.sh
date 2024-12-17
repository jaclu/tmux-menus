#!/bin/sh

if [ -z "$1" ]; then
  echo "Usage: $0 <search_string>"
  exit 1
fi

SEARCH="$1"
tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index}' | \
while read -r pane; do
  echo "== Searching in pane: $pane =="
  tmux capture-pane -pt "$pane" | grep --color=always "$SEARCH" && echo
done
