#!/bin/bash
# returns basename of filepath and removes extension if specified
function basename_custom {
    if [[ -n $1 ]]; then
        filepath=$1
        file_basename="${filepath##*/}"
        if [[ -n $2 ]]; then
            file_basename="${file_basename%.$2}"
        fi
        echo $file_basename
    else
        exit 1
    fi
}

# returns dirname from filepath
function dirname_custom {
    if [[ -n $1 ]]; then
        filepath=$1
        echo ${filepath%/*}
    fi
}

# Find line matching TEXT parse string and return it
function get_description {
    FILE="$1"
    while read line; do

        if [[ $line =~ ^OSSL-description: ]]; then
            line=${line#*'"'}
            line=${line%'"'*}
            echo "$line"
            break
        fi
    done <"$FILE"
}
