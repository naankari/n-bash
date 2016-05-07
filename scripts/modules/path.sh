#!/bin/bash

# Environment
#	N_HOME
#		Required: True
#	N_TEMPLATES
#		Required: True


_npathSourceFile="$N_HOME/path"
_npathSourceFileTemplate="$N_TEMPLATES/path"

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
	
        paths=$(_nReadEffectiveLines "$_npathSourceFile")
	for path in $paths; do
		PATH="$path:$PATH"
        done
        
	export PATH
}

_npathAppendPath() {
	path="$1"
	cwd=`pwd`
	if [[ $path = "" || $path = "." ]]; then
		path=$cwd
	fi

	path=$(_nIndirect "$path")

	if [[ -f $_npathSourceFile ]]; then
		exits=`cat "$_npathSourceFile" | grep -i "^$path$" | wc -l`
		if [[ $exits -gt 0 ]]; then
			echo "$path already exists in PATH"
			return
		fi
	fi

	echo "Adding $path in PATH ..."
	echo "Enter 'y' or 'yes' to confirm:"
	
	read input
	input=${input^^}
	
	if [[ $input != "Y" && $input != "YES" ]]; then
		echo "Exiting."
		return 1
	fi

	if [[ ! -f $_npathSourceFile ]]; then
                echo "Did not find file $_npathSourceFile to source path information"
                echo "Enter y to "Y" to create one and continue:"
                read input
                input=${input^^}
                if [[ $input = "Y" || $input = "YES" ]]; then
                        cp "$_npathSourceFileTemplate" "$_npathSourceFile"
                        echo "Created file $_npathSourceFile to source path information."
                else
                        echo "Exiting."
                        return 1
                fi
        fi

	echo "$path" >> "$_npathSourceFile"
	echo "Reloading PATH ..."
	_npathLoad
}

_npathLoad

alias pathAdd="_npathAppendPath"

