#!/bin/bash

# Environment
#       N_HOME
#               Required: False
#		Default Value: $HOME/.n
#       N_MASTER_SWITCH_FILE
#               Required: False
#               Default Value: $HOME/n-bash-on-off
#	N_MODULES_ENABLED_FILE
#		Required: False
#		Default Value: $N_HOME/n-modules-enabled



if [[ "$N_HOME" = "" ]]; then
	export N_HOME="$HOME/.n"
fi

_nMasterSwitchFile=${N_MASTER_SWITCH_FILE-"$HOME/n-bash-on-off"}
_nModulesEnabledFile=${N_MODULES_ENABLED_FILE-"$N_HOME/n-modules-enabled"}

_nInteractive=$-
_nLoad() {
	if [[ $_nInteractive != *i* ]]; then
        	# Shell is non-interactive. Stop.
        	return
	fi	
	
	source "$N_HOME/n-lib.sh"

	if [[ -f $_nMasterSwitchFile ]]; then
		switchState=$(_nReadEffectiveLine $_nMasterSwitchFile)
		switchState=${switchState,,}
		if [[ $switchState = "off" ]]; then
			echo "Found switch file $_nMasterSwitchFile with '$switchState' state. Will not setup nBash."
			return
		fi
	fi
	
	echo "Setting up nBash ..."	
	echo "Using $N_HOME as nBash Home."

	_nLoadModules

	echo "Finished setting up nBash."
}

_nLoadModules() {
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

