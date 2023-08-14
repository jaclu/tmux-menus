#!/usr/bin/env bash
#
#  Part of https://github.com/jaclu/AOK-Filesystem-Tools
#
#  Copyright (c) 2023: Jacob.Lundqvist@gmail.com
#
#  License: MIT
#
#  Runs shellcheck on all included scripts
#

prog_name=$(basename "$0")

echo "$prog_name"
echo

#
#  Ensure this is run in the intended location in case this was launched from
#  somewhere else.
#
cd /home/jaclu/.tmux/plugins/tmux-menus || {
    echo
    echo "ERROR: The AOK file tools needs to be saved to /opt/AOK for things to work!".
    echo
    exit 1
}


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

#!/bin/bash

do_shellcheck() {
    if [[ -n "${do_shellcheck}" ]]; then
	# -x follow source
        shellcheck -a -x -o all -e SC2250,SC2312 "${fname}" || exit 1
    fi
}

# Function to check if a string is in an array
string_in_array() {
    local target="$1"
    shift
    local array=("$@")

    for element in "${array[@]}"; do
        if [[ "$element" == "$target" ]]; then
            return 0  # Found the string in the array
        fi
    done

    return 1  # String not found in the array
}

do_posix_check() {
    echo "checking posix: $fname"
    do_shellcheck
    if [[ -n "${do_checkbashisms}" ]]; then
	checkbashisms -n -e -x "${fname}" || exit 1
    fi
}

do_bash_check() {
    echo "checking bash: $fname"
    do_shellcheck
}

do_posix() {
    echo
    echo "---  Posix  ---"
    for fname in "${items_posix[@]}"; do
	do_posix_check "$fname"
    done
}

do_bash() {
    echo
    echo "---  Bash  ---"
    for fname in "${items_bash[@]}"; do
	do_bash_check "$fname"
    done
}

do_python() {
    echo
    echo "---  python  ---"
    for fname in "${items_python[@]}"; do
	echo "$fname"
    done
}

list_file_types() {
    echo
    echo "---  File types found  ---"
    for f_type in "${file_types[@]}"; do
	echo "$f_type"
	echo
    done
}

mapfile -t all_files < <(find .)
excludes=(
    ./Alpine/cron/15min/dmesg_save
    ./Debian/etc/profile
    ./common_AOK/usr_local_bin/aok
)
prefixes=(
    ./.git
    ./.vscode
    ./Devuan/etc/update-motd.d
)
suffixes=(
    \~
)
file_types=()
items_posix=()
items_bash=()
items_python=()

for fname in "${all_files[@]}"; do
    [[ -d "$fname" ]] && continue

    for exclude in "${excludes[@]}"; do
	[[ "$fname" == "$exclude" ]] && continue 2
    done

    for prefix in "${prefixes[@]}"; do
	[[ "$fname" == "$prefix"* ]] && continue 2
    done

    for suffix in "${suffixes[@]}"; do
	[[ "$fname" == *"$suffix" ]] && continue 2
    done

    f_type="$(file -b "$fname")"

    if [[ "$f_type" == *"POSIX shell script"* ]]; then
	items_posix+=("$fname")
	continue
    elif [[ "$f_type" == *"Bourne-Again shell script"* ]]; then
	items_bash+=("$fname")
	continue
    elif [[ "$f_type" == *"Python script"* ]]; then
	items_python+=("$fname")
	continue
    elif ! string_in_array "$f_type" "${file_types[@]}"; then
	file_types+=("$f_type")
    fi
    #
    # Display uncathegorized
    #
    #[[ "$f_type" != *"ELF"* ]] && {
    # 	file "$fname"
    #	echo
    #}
done

do_posix
do_bash
do_python

# list_file_types
