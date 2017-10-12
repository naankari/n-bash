#!/bin/bash


# Profile
#    N_LOCAL
#        Required: True
#    N_PROFILE
#        Required: False
#        Default Value: <none>
#   N_PROFILE_EXECUTABLE_FILE_PREFIX
#       Required: False
#       Default Value: "$N_LOCAL/profile-"
#    N_PROFILE_SETUP_FN_PREFIX
#       Required: False
#       Default Value: "_setup_profile_"
#    N_PROFILE_TEARDOWN_FN_PREFIX
#       Required: False
#       Default Value: "_teardown_profile_"
#    N_PROFILE_EXPORT_AS
#       Required: False
#       Default Value: "workOn"

_nprofileExecutableFilePrefix="$(_nAbsolutePath "${N_PROFILE_EXECUTABLE_FILE_PREFIX-$N_LOCAL/profile-}")"
_nprofileSetupFnPrefix="${N_PROFILE_SETUP_FN_PREFIX-_setup_profile_}"
_nprofileTeardownFnPrefix="${N_PROFILE_TEARDOWN_FN_PREFIX-_teardown_profile_}"
_nprofileExportAs="${N_PROFILE_EXPORT_AS-workOn}"

_nProfileInvokeFn() {
    local fn="$1"
    if [[ "$(type -t $fn)" == "function" ]]; then
        _nLogOrEcho "Invoking function $fn ..."
        _nLogOrEcho "----- FUNCTION INVOCATION BEGIN -----"
        $fn
        local retVal=$?
        _nLogOrEcho "----- FUNCTION INVOCATION END -----"
        if [[ $retVal -eq 0 ]]; then
            _nLogOrEcho "Function invoked successfully."
        else
            _nErrorOrEcho "Function failed with errors."
        fi
    else
        _nWarnOrEcho "Function $fn does not exist."
    fi
}

_nprofileInvokeSetup() {
    local profile="$1"
    local profileFile="$_nprofileExecutableFilePrefix$profile"
    if [[ ! -f $profileFile ]]; then
        _nWarnOrEcho "Source file $profileFile does not exist."
    else
        _nLogOrEcho "Sourcing file $profileFile ..."
        _nLogOrEcho "----- SOURCE BEGIN -----"
        source "$profileFile"
        _nLogOrEcho "----- SOURCE END -----"
    fi
    _nProfileInvokeFn "$_nprofileSetupFnPrefix$profile"
}

_nprofileLoad() {
    local profile="$1"
    if [[ "$profile" == "" ]]; then
        profile="default"
    fi
    _nLogOrEcho "Setting up $profile profile ..."
    if [[ "$profile" != "default" ]]; then
        _nprofileInvokeSetup "default"
    fi
    _nprofileInvokeSetup "$profile"
    export N_PROFILE="$profile"
    _nLogOrEcho "Profile setup done."
}

_nprofileInit() {
    if [[ "$N_PROFILE" != "" ]]; then
        _nprofileLoad "$N_PROFILE"
    else
        _nLog "Not loading any profile."
    fi
}

_nprofileInvokeTeardown() {
    local profile="$1"
    _nProfileInvokeFn "$_nprofileTeardownFnPrefix$profile"
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

_nprofileCurrent() {
    echo "$N_PROFILE"
}

_nprofileReinit() {
    local currentProfile="$(_nprofileCurrent)"
    local newProfile="${1-$currentProfile}"
    if [[ "$currentProfile" != "" ]]; then
        _nprofileUnload "$currentProfile"
    fi
    _nprofileLoad "$newProfile"
}

_nprofileUsage() {
    echo "Usage:"
    echo "$_nprofileExportAs"
    echo "    Manage development profile on shell."
    echo "[Options]"
    echo "    <profile>"
    echo "        Load the provided profile."
    echo "    --current"
    echo "        Load the provided profile."
    echo "    -?"
    echo "        Show this message."
}

_nprofile() {
    local input="$1"

    if [[ "$input" == "-?" ]]; then
        _nprofileUsage
        return $?
    fi

    if [[ "$input" == "--current" ]]; then
        _nprofileCurrent
        return $?
    fi

    _nprofileReinit "$input"
    return $?
}

_nprofileInit

alias $_nprofileExportAs="_nprofile"

_nLog "Use '$_nprofileExportAs <profile>' to setup/switch profile."
_nLog "Use '$_nprofileExportAs -?' to know more about this command."

