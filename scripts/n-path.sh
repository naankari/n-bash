#!/bin/bash

# Environment
#	N_HOME
#		Required: True
#       N_PATH_SOURCE_FILE
#               Required: False
#               Default Value: "$N_HOME/n-path"



_npathSourceFile=${N_PATH_SOURCE_FILE-"$N_HOME/n-path"}

_npathLoad() {
	if [[ "$_N_PATH_ORIG" != "" ]]; then
        	export PATH="$_N_PATH_ORIG"
	fi

	if [[ ! -f $_npathSourceFile ]]; then
		echo "Did not find $_npathSourceFile to source path information"
		return
	fi

        echo "Sourcing path info from $_npathSourceFile"
        export _N_PATH_ORIG="$PATH"
	
        paths=$(_nReadEffectiveLines $_npathSourceFile)
	for path in $paths; do
		PATH="$path:$PATH"
        done
        
	export PATH
}

_npathAppendPath() {
	if [[ ! -f $_npathSourceFile ]]; then
		echo "Did not find $_npathSourceFile to source path information"
		exit 1
	fi
	
	path="$1"
	cwd=`pwd`
	if [[ $path = "" || $path = "." ]]; then
		path=$cwd
	fi

	path=$(_nIndirect $path)

	exits=`cat $_npathSourceFile | grep -i "^$path$" | wc -l`
	if [[ $exits -gt 0 ]]; then
		echo "$path already exists in PATH"
		return
	fi

	echo "Adding $path in PATH ..."
	echo "Enter 'y' or 'yes' to confirm:"
	
	read input
	input=${input^^}
	
	if [[ $input = "Y" || $input = "YES" ]]; then
		echo $path >> $_npathSourceFile
		echo "Reloading PATH ..."
		_npathLoad
	fi
}

_npathLoad

alias pathAdd="_npathAppendPath"
