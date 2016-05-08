#!/bin/bash

# Environment
#       N_HOME
#               Required: False
#        Default Value: $HOME/.n
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

    logLevel=$(_nToLower "$N_LOG_LEVEL")
    if [[ $logLevel != "verbose" && $logLevel != "warn" && $logLevel != "error" ]]; then
        export N_LOG_LEVEL="verbose"
    fi

    if [[ -f $_nMasterSwitchFile ]]; then
        switchState=$(_nReadEffectiveLine "$_nMasterSwitchFile")
        switchState=$(_nToLower "$switchState")
        if [[ $switchState = "off" ]]; then
            _nLog "Found switch file $_nMasterSwitchFile with '$switchState' state. Will not setup nBash."
            return
        fi
    fi

    _nLog "Setting up nBash ..."
    _nLog "Using $N_HOME as nBash Home."

    _nLoadModules

    _nLog "Finished setting up nBash."

    _nLog "Running diagnostics ..."
    _nDiagnostics
    _nLog "Diagnostics completed."
}

_nLoadModules() {
    if [[ ! -f $_nModulesEnabledFile ]]; then
        _nWarn "Could not read enabled modules file $_nModulesEnabledFile."
        _nWarn "Copying from default file $_nModulesEnalbedFileDefault ..."
        cp "$_nModulesEnalbedFileDefault" "$_nModulesEnabledFile"
    fi

    _nLog "Loading modules from file $_nModulesEnabledFile ..."
    modules=$(_nReadEffectiveLines "$_nModulesEnabledFile")
    for module in $modules; do
        _nLog "Loading module $module ..."
        _nSourceIf "$N_MODULES/$module.sh"
    done
    _nLog "Finished loading modules."
}

_nDiagnostics() {
    _nLibDiagnostics
}

_nLoad
