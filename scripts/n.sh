#!/bin/bash


#   Environment
#       N_HOME
#           Required: False
#           Default Value: "$HOME/.n"
#       N_LOCAL
#           Required: False
#           Default Value: "$N_HOME/local"
#       N_LIB
#           Required: False
#           Default Value: "$N_HOME/scripts/lib"
#       N_MODULES_DIR
#           Required: False
#           Default Value: "$N_HOME/scripts/modules"
#       N_OPTIONS_DIR
#           Required: False
#           Default Value: "$N_HOME/scripts/options"
#       N_TEMPLATES_DIR
#           Required: False
#           Default Value: "$N_HOME/scripts/templates"
#       N_DEFAULTS_DIR
#           Required: False
#           Default Value: "$N_HOME/scripts/defaults"
#       N_MASTER_SWITCH_FILE
#           Required: False
#           Default Value: "$HOME/n-bash-on-off"
#       N_MODULES_ENABLED_FILE
#           Required: False
#           Default Value: "$N_LOCAL/modules-enabled"; initialized from default "$N_DEFAULTS_DIR/modules-enabled"

if [[ "$N_HOME" == "" ]]; then
    export N_HOME="$HOME/.n"
fi

export N_LOCAL="${N_LOCAL-$N_HOME/local}"
export N_LIB="${N_LIB-$N_HOME/scripts/lib}"
export N_MODULES_DIR="${N_MODULES_DIR-$N_HOME/scripts/modules}"
export N_OPTIONS_DIR="${N_OPTIONS_DIR-$N_HOME/scripts/options}"
export N_TEMPLATES_DIR="${N_TEMPLATES_DIR-$N_HOME/scripts/templates}"
export N_DEFAULTS_DIR="${N_DEFAULTS_DIR-$N_HOME/scripts/defaults}"

source "$N_LIB/lib.sh"

_nMasterSwitchFile="$(_nAbsolutePath "${N_MASTER_SWITCH_FILE-$HOME/n-bash-on-off}")"
_nModulesEnabledFile="$(_nAbsolutePath "${N_MODULES_ENABLED_FILE-$N_LOCAL/modules-enabled}")"
_nModulesEnalbedFileDefault="$(_nAbsolutePath "$N_DEFAULTS_DIR/modules-enabled")"

_nInit() {
    export N_LOAD_STAGE="init"

    _nInitInternal
    local status=$?

    export N_LOAD_STAGE="runtime"
    return $status 
}

_nInitInternal() {
    local interactive=$-
    if [[ $interactive != *i* ]]; then
        # Shell is non-interactive. Stop.
        return
    fi    

    local logLevel=$(_nToLower "$N_LOG_LEVEL")
    if [[ "$logLevel" != "verbose" && "$logLevel" != "warn" && "$logLevel" != "error" ]]; then
        export N_LOG_LEVEL="verbose"
    fi

    if [[ -f $_nMasterSwitchFile ]]; then
        local switchState=$(_nReadEffectiveLine "$_nMasterSwitchFile")
        switchState=$(_nToLower "$switchState")
        if [[ "$switchState" == "off" ]]; then
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
        if [[ -f $_nModulesEnalbedFileDefault ]]; then
            _nLog "Copying from default file $_nModulesEnalbedFileDefault ..."            
            _nEnsureParentDirectoryExists "$_nModulesEnabledFile"
            cp "$_nModulesEnalbedFileDefault" "$_nModulesEnabledFile"
        else
            _nWarn "Skipping loading modues!"
            return
        fi
    fi

    _nLog "Loading modules from file $_nModulesEnabledFile ..."
    local modules=$(_nReadEffectiveLines "$_nModulesEnabledFile")
    for module in $modules; do
        _nLog "Loading module $module ..."
        _nSourceIf "$N_MODULES_DIR/$module.sh"
    done
    _nLog "Finished loading modules."
}

_nDiagnostics() {
    _nLibDiagnostics
}

_nInit

