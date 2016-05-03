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

