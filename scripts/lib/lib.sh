#!/bin/bash



_nSourceIf() {
        path=$(_nIndirect "$1")
        [ -f $path ] && source "$path" || "File $path could not be sourced."
}

_nIndirect() {
        path="$1"
	path=${path/\~/$HOME}
	eval path="$path"
        echo "$path"
}

_nReadEffectiveLines() {
	path=$(_nIndirect "$1")
	if [[ ! -f $path ]]; then
		echo ""
		return
	fi
	lines=$(cat "$path" | sed -e 's/^\s*//;s/\s*$//' | grep -iv "^[ \t]*$" | grep -iv "^[ \t]*#.*$")
	for line in $lines; do
		_nIndirect "$line"
	done
}

_nReadEffectiveLine() {
	content=$(_nReadEffectiveLines "$1")
	content=$(echo "$content" | head -1)
	echo "$content"
}

_nFindFirstFileThatExists() {
	options=$(_nReadEffectiveLines "$1")

	for option in $options; do
		if [[ -f $option ]]; then
			echo "$option"
			return
		fi
	done
}
