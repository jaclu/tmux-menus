#!/usr/bin/env bash
#
#  Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  Does shellcheck on all relevant scripts in this project
#

CURRENT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)

cd "$CURRENT_DIR" || return

checkables=(

    #  Obviously self exam should be done :)
    shellchecker.sh

    menus.tmux

    scripts/*.sh

    items/*.sh

    items/extras/*.sh
)

do_shellcheck="$(command -v shellcheck)"
do_checkbashisms="$(command -v checkbashisms)"

if [[ "${do_shellcheck}" = "" ]] && [[ "${do_checkbashisms}" = "" ]]; then
    echo "ERROR: neither shellcheck nor checkbashisms found, can not proceed!"
    exit 1
fi

printf "Using: "
if [[ -n "${do_shellcheck}" ]]; then
    printf "%s " "shellcheck"
fi
if [[ -n "${do_checkbashisms}" ]]; then
    printf "%s " "checkbashisms"
    #  shellcheck disable=SC2154
    if [[ "$build_env" -eq 1 ]]; then
        if checkbashisms --version | grep -q 2.21; then
            echo
            echo "WARNING: this version of checkbashisms runs extreamly slowly on iSH!"
            echo "         close to a minute/script"
        fi
    fi
fi
printf "\n\n"

for script in "${checkables[@]}"; do
    #  abort as soon as one lists issues
    echo "Checking: ${script}"
    if [[ "${do_shellcheck}" != "" ]]; then
        shellcheck -x -a -o all -e SC2250,SC2312 "${script}" || exit 1
    fi
    if [[ "${do_checkbashisms}" != "" ]]; then
        checkbashisms -n -e -x "${script}" || exit 1
    fi
done
