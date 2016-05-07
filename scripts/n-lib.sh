#!/bin/bash



_nSourceIf() {
        path=$(_nFullPath $1)
        [ -f $path ] && source $path || "File $path could not be sourced."
}

_nFullPath() {
        path="$1"
	path=${path/\~/$HOME}
        echo $path
}

_nReadEffectiveLines() {
	path=$(_nFullPath $1)
	if [[ ! -f $path ]]; then
		echo ""
		return
	fi
	content=`cat "$path" | sed -e 's/^\s*//;s/\s*$//' | grep -iv "^[ \t]*$" | grep -iv "^[ \t]*#.*$"`
	echo $content
}

_nReadEffectiveLine() {
	content=$(_nReadEffectiveLines $1)
	content=`echo $content | head -1`
	echo $content
}

