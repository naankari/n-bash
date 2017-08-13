#!/bin/bash


# Profile
#    N_HOME
#        Required: True
#    N_PROFILE
#        Required: False
#        Default Value: "none"
#   N_PROFILE_EXECUTABLE_FILE_PREFIX
#       Required: False
#       Default Value: "$N_HOME/profile-"
#    N_PROFILE_SETUP_FN_PREFIX
#       Required: False
#       Default Value: "_setup_profile_"
#    N_PROFILE_TEARDOWN_FN_PREFIX
#       Required: False
#       Default Value: "_teardown_profile_"
#    N_PROFILE_EXPORT_AS
#       Required: False
#       Default Value: "workOn"


_nprofileExecutableFilePrefix="${N_PROFILE_EXECUTABLE_FILE_PREFIX-$N_HOME/profile-}"
_nprofileSetupFnPrefix="${N_PROFILE_SETUP_FN_PREFIX-_setup_profile_}"
_nprofileTeardownFnPrefix="${N_PROFILE_TEARDOWN_FN_PREFIX-_teardown_profile_}"
_nprofileExportAs="${N_PROFILE_EXPORT_AS-workOn}"

_nprofileLoad() {
    local profile="$1"
    if [[ "$profile" == "" ]]; then
        profile="default"
    fi
    _nLog "Setting up $profile profile ..."
    if [[ "$profile" != "default" ]]; then
        _nprofileInvokeSetup "default"
    fi
    _nprofileInvokeSetup "$profile"
     export N_PROFILE="$profile"
    _nLog "Profile setup done."
}

_nprofileInvokeSetup() {
    local profile="$1"
    local profileFile="$_nprofileExecutableFilePrefix$profile"
    if [[ ! -f $profileFile ]]; then
        _nError "Source file $profileFile does not exist."
    else
        _nLog "Sourcing file $profileFile ..."
           _nLog "----- SOURCE BEGIN -----"
         source "$profileFile"
        _nLog "----- SOURCE END -----"
    fi
    _nProfileInvokeFn "$_nprofileSetupFnPrefix$profile"
}

_nprofileUnload() {
    local profile="$1"
    _nLog "Unloading profile $profile ..."
    _nprofileInvokeTeardown "$profile"
    if [[ $profile != "default" ]]; then
        _nprofileInvokeTeardown "default"
    fi
    unset N_PROFILE
    _nLog "Profile unloading done."
}

_nprofileInvokeTeardown() {
    local profile="$1"
    _nProfileInvokeFn "$_nprofileTeardownFnPrefix$profile"
}

_nProfileInvokeFn() {
    local fn="$1"
    if [[ "$(type -t $fn)" == "function" ]]; then
        _nLog "Invoking function $fn ..."
        _nLog "----- FUNCTION INVOCATION BEGIN -----"
        $fn
        local retVal=$?
        _nLog "----- FUNCTION INVOCATION END -----"
        if [[ $retVal -eq 0 ]]; then
            _nLog "Function invoked successfully."
        else
            _nError "Function failed with errors."
        fi
    else
        _nError "Function $fn does not exist."
    fi
}

_nprofileReinit() {
    local currentProfile="$N_PROFILE"
    local newProfile="${1-$N_PROFILE}"
    if [[ "$currentProfile" != "" ]]; then
        _nprofileUnload "$currentProfile"
    fi
    _nprofileLoad "$newProfile"
}

if [[ "$N_PROFILE" != "" ]]; then
    _nprofileLoad "$N_PROFILE"
else
    _nLog "Not loading any profile."
fi

alias $_nprofileExportAs="_nprofileReinit"

_nLog "Use '$_nprofileExportAs <profile>' to setup/switch profile"
