#!/bin/bash

# Environment
#       N_HOME
#               Required: False
#		Default Value: $HOME/.n
#       N_MASTER_SWITCH_FILE
#               Required: False
#               Default Value: $HOME/n-bash-on-off



if [[ "$N_HOME" = "" ]]; then
	export N_HOME="$HOME/.n"
fi
export N_LIB="$N_HOME/scripts/lib"
export N_MODULES="$N_HOME/scripts/modules"
export N_OPTIONS="$N_HOME/scripts/options"
export N_TEMPLATES="$N_HOME/scripts/templates"
export N_DEFAULTS="$N_HOME/scripts/defaults"

_nMasterSwitchFile=${N_MASTER_SWITCH_FILE-"$HOME/n-bash-on-off"}

_nModulesEnabledFile="$N_HOME/modules-enabled"
_nModulesEnalbedFileDefault="$N_DEFAULTS/modules-enabled"

_nInteractive=$-
_nLoad() {
	if [[ $_nInteractive != *i* ]]; then
        	# Shell is non-interactive. Stop.
        	return
	fi	
	
	source "$N_LIB/lib.sh"

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
        else
                echo "Could not read enabled modules file $_nModulesEnabledFile."
		echo "Copying from default file $_nModulesEnalbedFileDefault ..."
		cp "$_nModulesEnalbedFileDefault" "$_nModulesEnabledFile"
        fi
       	modules=$(_nReadEffectiveLines $_nModulesEnabledFile)
       	for module in $modules; do
       		echo "Loading module $module ..."
           	_nSourceIf "$N_MODULES/$module.sh"
   	done
  	echo "Finished loading modules."
}

_nLoad

