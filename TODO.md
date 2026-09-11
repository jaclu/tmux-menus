# TODO

screenshots without danger zone
<img width="252" height="369" alt="Handling Pane"
  src="https://github.com/user-attachments/assets/2437cc87-4dd7-4413-98df-a8082771a202" />
<img width="252" height="323" alt="Handling Window"
  src="https://github.com/user-attachments/assets/1b7e2c27-d1dd-4417-ba3a-85557f2b5cfb" />
<img width="251" height="218" alt="Handling Sessions"
  src="https://github.com/user-attachments/assets/f325d4c4-b0cf-4b9c-9045-f898a89f5eb0" />

## popup panes

starting with 3.7 they have F1 to describe keys - default disable related overlays

## optimization

unless enabled via tmux.conf

and if no log_file - short circuit safe_now to always return 0, or perhaps
a counter if 0 causes issues

choose-tree - 1.8 - not usable in 1.7

- flags
  - -Z 2.7

## Floating pane menu

implement checks that move and resize doesn't go outside window borders.

## Revert to default

an empty setting like "" / '' should revert to default

## vscode faking to run inside t2

```bash
export TMUX=/private/tmp/tmux-501/501-serv2,39012,0
export TMUX_BIN=/Users/jaclu/git_repos/others/tmux/tmux
export TMUX_OUTER=/private/tmp/tmux-501/501-default,64195,0

# Is this needed?
export TMUX_PLUGIN_MANAGER_PATH=/Users/jaclu/t2/tmux/plugins/
```

## @menus_border_type might be obsoleted

- 3.4
  menu-style
  menu-selected-style [display-menu -H]
  menu-border-style
  menu-border-lines

### works

set -g @menus_border_type 'rounded'

ends up as: -b rounded

### no effect

set -g @menus_simple_style_selected 'rounded'

ends up as -H -rounded

### obsoleted in tmux 3.4 by

$TMUX_BIN set-option menu-border-lines rounded

## Speed test on JacDroid

- next-3.8 using old mtime
  [23:13:56] [1655] Menu items/main.sh - processing time: 0.0635448
  [23:14:05] [1990] Menu items/main.sh - processing time: 0.0514686
  [23:14:32] [2925] Menu items/main.sh - processing time: 0.247848
  [23:14:34] [3035] Menu items/panes.sh - processing time: 0.185276
  [23:14:37] [3136] Menu items/main.sh - processing time: 0.262895
  [23:14:38] [3187] Menu items/panes.sh - processing time: 0.078198
  [23:14:39] [3261] Menu items/main.sh - processing time: 0.0691426
  [23:14:40] [3315] Menu items/panes.sh - processing time: 0.0676017
  [23:14:41] [3408] Menu items/main.sh - processing time: 0.0930328
  [23:14:42] [3453] Menu items/panes.sh - processing time: 0.0652826
  [23:14:44] [3489] Menu items/main.sh - processing time: 0.0729706
  [23:14:45] [3554] Menu items/panes.sh - processing time: 0.0591846
  [23:14:46] [3589] Menu items/main.sh - processing time: 0.0538998
  [23:14:47] [3649] Menu items/panes.sh - processing time: 0.0608785
  [23:14:48] [3713] Menu items/main.sh - processing time: 0.0606668
  [23:14:48] [3751] Menu items/panes.sh - processing time: 0.0577908

## no display using mtime

### older vers

```shell
gco c9648b6f0dffc87b6cdfab7012938315b3a87b56
rm cache -rf
./scripts/plugin_init.sh
export TMUX_MENUS_NO_DISPLAY=1
time items/main.sh # save times from the 2nd 3rd or so to ensure cache is ready
```

some data: 0.183 0.174 0.170 0.180 0.179 0.183

### no mtime vers

```shell
gco devel
rm cache -rf
./scripts/plugin_init.sh
export TMUX_MENUS_NO_DISPLAY=1
time items/main.sh # save times from the 2nd 3rd or so to ensure cache is ready
```

some data: 0.183 0.174 0.170 0.180 0.179 0.183

## Leftovers

- tmux 3.7c apt bin
  - validate_menu_cache=1
    [21:00:37] [30788] Menu items/main.sh - processing time: 0.114456
    [21:00:45] [31063] Menu items/main.sh - processing time: 0.122588
    [21:00:47] [31163] Menu items/panes.sh - processing time: 0.128983
    [21:00:48] [31201] Menu items/main.sh - processing time: 0.126711
    [21:00:50] [31304] Menu items/panes.sh - processing time: 0.122838
    [21:00:51] [31357] Menu items/main.sh - processing time: 0.126203
    [21:00:52] [31410] Menu items/panes.sh - processing time: 0.117074
    [21:00:53] [31505] Menu items/main.sh - processing time: 0.128616
    [21:00:54] [31557] Menu items/panes.sh - processing time: 0.121927

  - validate_menu_cache=0
    [21:01:22] [32335] Menu items/main.sh - processing time: 0.0596828
    [21:01:23] [32413] Menu items/panes.sh - processing time: 0.0625184
    [21:01:24] [32453] Menu items/main.sh - processing time: 0.0556762
    [21:01:26] [32482] Menu items/panes.sh - processing time: 0.0634542
    [21:01:28] [32576] Menu items/main.sh - processing time: 0.0598707
    [21:01:30] [32619] Menu items/panes.sh - processing time: 0.0598464
    [21:01:31] [32691] Menu items/main.sh - processing time: 0.0706663
    [21:01:32] [32758] Menu items/panes.sh - processing time: 0.0568132

- tmux next-3.8 - debug build
  - validate_menu_cache=1
    [21:07:03] [9525] Menu items/panes.sh - processing time: 0.119709
    [21:07:04] [9574] Menu items/main.sh - processing time: 0.122193
    [21:07:05] [9619] Menu items/panes.sh - processing time: 0.127764
    [21:07:06] [9704] Menu items/main.sh - processing time: 0.121479
    [21:07:07] [9754] Menu items/panes.sh - processing time: 0.119486
    [21:07:09] [9865] Menu items/main.sh - processing time: 0.121845
    [21:07:11] [9958] Menu items/panes.sh - processing time: 0.126521
    [21:07:13] [10016] Menu items/main.sh - processing time: 0.121206
    [21:07:14] [10096] Menu items/panes.sh - processing time: 0.123152
    [21:07:15] [10138] Menu items/main.sh - processing time: 0.119242
    [21:07:16] [10195] Menu items/panes.sh - processing time: 0.122217
    [21:07:17] [10241] Menu items/main.sh - processing time: 0.129944
    [21:07:18] [10298] Menu items/panes.sh - processing time: 0.125688
    [21:07:19] [10348] Menu items/main.sh - processing time: 0.128049
    [21:07:20] [10391] Menu items/panes.sh - processing time: 0.119924
    [21:07:22] [10483] Menu items/main.sh - processing time: 0.129572
    [21:07:22] [10525] Menu items/panes.sh - processing time: 0.127189
    [21:07:24] [10589] Menu items/main.sh - processing time: 0.125334
    [21:07:25] [10664] Menu items/panes.sh - processing time: 0.125072
  - validate_menu_cache=0
    [21:06:05] [7512] Menu items/main.sh - processing time: 0.0573611
    [21:06:06] [7541] Menu items/panes.sh - processing time: 0.0565319
    [21:06:07] [7562] Menu items/main.sh - processing time: 0.0608571
    [21:06:08] [7632] Menu items/panes.sh - processing time: 0.060226
    [21:06:09] [7670] Menu items/main.sh - processing time: 0.0583584
    [21:06:09] [7708] Menu items/panes.sh - processing time: 0.0591621
    [21:06:10] [7775] Menu items/main.sh - processing time: 0.0604794
    [21:06:11] [7798] Menu items/panes.sh - processing time: 0.0611615
    [21:06:12] [7848] Menu items/main.sh - processing time: 0.0615251
    [21:06:12] [7886] Menu items/panes.sh - processing time: 0.062295
    [21:06:13] [7939] Menu items/main.sh - processing time: 0.0579476
    [21:06:14] [7976] Menu items/panes.sh - processing time: 0.0602448
    [21:06:15] [8018] Menu items/main.sh - processing time: 0.0624926
    [21:06:16] [8103] Menu items/panes.sh - processing time: 0.0635226
    [21:06:17] [8141] Menu items/main.sh - processing time: 0.0571673
    [21:06:18] [8184] Menu items/panes.sh - processing time: 0.0657506
    [21:06:19] [8269] Menu items/main.sh - processing time: 0.0596087
    [21:06:20] [8308] Menu items/panes.sh - processing time: 0.0590022
    [21:06:21] [8366] Menu items/main.sh - processing time: 0.0613916
    [21:06:22] [8429] Menu items/panes.sh - processing time: 0.0604677
    [21:06:24] [8509] Menu items/main.sh - processing time: 0.0610082
    [21:06:24] [8552] Menu items/panes.sh - processing time: 0.0608983
    [21:06:25] [8568] Menu items/main.sh - processing time: 0.0617487
