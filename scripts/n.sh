#!/bin/bash

# Environment
#       N_HOME
#               Required: False
#		Default Value: $HOME/.n
#       N_NO_N_BASH_FILE
#               Required: False
#               Default Value: $HOME/no-n-bash
#	N_MODULES_ENABLED_FILE
#		Required: False
#		Default Value: $N_HOME/n-modules-enabled

if [[ "$N_HOME" = "" ]]; then
	export N_HOME="$HOME/.n"
fi

_nNoNBashFile=${N_NO_N_BASH_FILE-"$HOME/no-n-bash"}
_nModulesEnabledFile=${N_MODULES_ENABLED_FILE-"$N_HOME/n-modules-enabled"}

_nInteractive=$-
_nLoad() {
	if [[ $_nInteractive != *i* ]]; then
        	# Shell is non-interactive. Stop.
        	return
	fi	
	
	if [[ -f $_nNoNBashFile ]]; then
		echo "Found $_nNoNBashFile file. Will not setup nBash"
		return
	fi
	
	echo "Setting up nBash ..."	
	echo "Using $N_HOME as nBash Home."

	_nLoadModules

	echo "Finished setting up nBash."
}

_nLoadModules() {
	source "$N_HOME/n-lib.sh"

        if [[ -f $_nModulesEnabledFile ]]; then
                echo "Loading modules from file $_nModulesEnabledFile ..."
                while read module; do
                        if [[ $module = "" ]]; then
                                continue
                        fi
                        echo "Loading module $module ..."
                        _nSourceIf "$N_HOME/n-$module.sh"
                done < $_nModulesEnabledFile
                echo "Finished loading modules."
        else
                echo "Could not read enabled modules file $_nModulesEnabledFile."
        fi
}

_nLoad

