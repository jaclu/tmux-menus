# todo

## Potential new items

- Client
  - Detach other clients:
  - list connected clients
  - Detach this client
    tmux detach-client
  - Detach other clients
    tmux detach-client -a
  - Detach all other clients from current session
    tmux detach-client -a -s "$(tmux display-message -p '#{session_name}')"
  - Switch session

- Display commands - if no binds, say so and go to default

- Window
  <!-- - list connected clients ?
  - Detach other clients ?
  - Detach from this ?updated -->
  - Scroll window larger than screen
    prefix S-Arrow

## Plan

### Inspect if this works as intended

has_lf_not_at_end
