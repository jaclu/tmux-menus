#!/bin/sh
#
#  Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  Index over the various diacritics menus
#

static_content() {
    set -- \
        0.0 M Left "Back to Missing Keys  $nav_prev" "$d_odd_chars"/missing_keys.sh \
        0.0 M Home "Back to Main menu     $nav_home" main.sh \
        0.0 S \
        0.0 M A "Diacritics - a A      $nav_next" "$d_odd_chars"/diacritics_a.sh \
        0.0 M C "Diacritics - c C      $nav_next" "$d_odd_chars"/diacritics_c.sh \
        0.0 M D "Diacritics - c D      $nav_next" "$d_odd_chars"/diacritics_d.sh \
        0.0 M E "Diacritics - e E      $nav_next" "$d_odd_chars"/diacritics_e.sh \
        0.0 M G "Diacritics - g G      $nav_next" "$d_odd_chars"/diacritics_g.sh \
        0.0 M H "Diacritics - h H      $nav_next" "$d_odd_chars"/diacritics_h.sh \
        0.0 M I "Diacritics - i I      $nav_next" "$d_odd_chars"/diacritics_i.sh \
        0.0 M K "Diacritics - k K      $nav_next" "$d_odd_chars"/diacritics_k.sh \
        0.0 M L "Diacritics - l L      $nav_next" "$d_odd_chars"/diacritics_l.sh \
        0.0 M N "Diacritics - n N      $nav_next" "$d_odd_chars"/diacritics_n.sh \
        0.0 M O "Diacritics - o O      $nav_next" "$d_odd_chars"/diacritics_o.sh \
        0.0 M R "Diacritics - r R      $nav_next" "$d_odd_chars"/diacritics_r.sh \
        0.0 M S "Diacritics - s S      $nav_next" "$d_odd_chars"/diacritics_s.sh \
        0.0 M T "Diacritics - t T      $nav_next" "$d_odd_chars"/diacritics_t.sh \
        0.0 M U "Diacritics - u U      $nav_next" "$d_odd_chars"/diacritics_u.sh \
        0.0 M W "Diacritics - w W      $nav_next" "$d_odd_chars"/diacritics_w.sh \
        0.0 M Y "Diacritics - y Y      $nav_next" "$d_odd_chars"/diacritics_y.sh \
        0.0 M Z "Diacritics - z Z      $nav_next" "$d_odd_chars"/diacritics_z.sh
    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Diacritics"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(dirname -- "$(realpath "$0")")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
