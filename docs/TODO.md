# Plan

## WhipTail

- menu_reload is not working, so disabled

## external_tools/dropbox.sh

toggle not working

## Pane titles

Add items, enable/disable show pane titles

## env init

### menu / general-script start

- check nocache hint
  - get tmux options - done
- read param cache if found - done
- plugin init

### read param cache

- read file
- override with dbg variables on each read?

### plugin init

- check tmux.conf cache state
  - set nocache hint
  - get tmux options - done
- param cache absent
  - create param cache - done
- tmux.conf age < param cache age
  - create param cache - done
- dbg variables vs param cache?
  - create param cache - done
- read param cache

### create param cache

- get tmux options
  - use debug variable overrides
- write param cache
- read it to ensure correct setting are used?

## reorganize files

plugins.sh -> tools
