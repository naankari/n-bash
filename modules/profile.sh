#!/bin/bash


# Profile
#    N_CURRENT_SHELL
#        Required: True
#    N_CONFIG_DIR
#        Required: True
#   N_DEFAULTS_DIR
#       Required: True
#    N_PROFILE
#        Required: False
#        Default Value: <none>
#   N_PROFILE_EXECUTABLE_FILE_PREFIX
#       Required: False
#       Default Value: "$N_CONFIG_DIR/profile-"
#    N_PROFILE_SETUP_FN_PREFIX
#       Required: False
#       Default Value: "_setup_profile_"
#    N_PROFILE_TEARDOWN_FN_PREFIX
#       Required: False
#       Default Value: "_teardown_profile_"
#    N_PROFILE_EXPORT_AS
#       Required: False
#       Default Value: "workOn"

_nprofileExecutableFilePrefix="$(_nToAbsolutePath "${N_PROFILE_EXECUTABLE_FILE_PREFIX-$N_CONFIG_DIR/profile-}")"
_nprofileSetupFnPrefix="${N_PROFILE_SETUP_FN_PREFIX-_setup_profile_}"
_nprofileTeardownFnPrefix="${N_PROFILE_TEARDOWN_FN_PREFIX-_teardown_profile_}"
_nprofileExportAs="${N_PROFILE_EXPORT_AS-workOn}"

_nProfileInvokeFn() {
    local fn="$1"
    if [[ $(_nDoesFunctionExist $fn) == 1 ]]; then
        _nLogOrEcho "Invoking function $fn ..."
        _nLogOrEcho "----- FUNCTION INVOCATION BEGINS -----"
        $fn
        local retVal=$?
        _nLogOrEcho "----- FUNCTION INVOCATION ENDS -----"
        if [[ $retVal -eq 0 ]]; then
            _nLogOrEcho "Function invoked successfully."
        else
            _nErrorOrEcho "Function failed with errors!"
        fi
    else
        _nWarnOrEcho "Function $fn does not exist!"
    fi
}

_nprofileLoadIndividualProfile() {
    local profile="$1"
    local profileFile="${_nprofileExecutableFilePrefix}${profile}"

    if [[ $(_nDoesFileExist "$profileFile") == 1 ]]; then
        _nSourceIf "$profileFile"
        _nProfileInvokeFn "${_nprofileSetupFnPrefix}${profile}"
        _nProfileInvokeFn "${_nprofileSetupFnPrefix}${profile}_${N_CURRENT_SHELL}"
    else
        _nWarnOrEcho "Profile file '$(_nToAbsolutePath '${profileFile}')' not found. You can copy default file from '$(_nToAbsolutePath '${N_DEFAULTS_DIR}/profile-default')' and rename accordingly!"
    fi
}

_nprofileLoadProfile() {
    local profile="$1"

    _nLogOrEcho "Setting up $profile profile ..."
    if [[ "$profile" != "default" ]]; then
        _nprofileLoadIndividualProfile "default"
    fi
    _nprofileLoadIndividualProfile "$profile"
    export N_PROFILE="$profile"
    _nLogOrEcho "Setting up profile done."
}

_nprofileInit() {
    if [[ "$N_PROFILE" != "" ]]; then
        _nprofileLoadProfile "$N_PROFILE"
    else
        _nLog "Not loading any profile."
    fi
}

_nprofileInvokeTeardown() {
    local profile="$1"

    _nProfileInvokeFn "${_nprofileTeardownFnPrefix}${profile}"
    _nProfileInvokeFn "${_nprofileTeardownFnPrefix}${profile}_${N_CURRENT_SHELL}"
}

_nprofileUnloadProfile() {
    local profile="$1"
    echo "Unloading profile $profile ..."
    _nprofileInvokeTeardown "$profile"
    if [[ $profile != "default" ]]; then
        _nprofileInvokeTeardown "default"
    fi
    unset N_PROFILE
    echo "Profile unloading done."
}

_nprofileUnloadCurrentProfile() {
    local currentProfile="$(_nprofileCurrent)"
    if [[ "$currentProfile" == "" ]]; then
        echo "[ERROR] No current profile loaded."
        return 1
    fi

    _nprofileUnloadProfile "$currentProfile"
}

_nprofileReloadCurrentProfile() {
    local currentProfile="$(_nprofileCurrent)"
    if [[ "$currentProfile" == "" ]]; then
        echo "[ERROR] No current profile loaded."
        return 1
    fi
    _nprofileUnloadProfile "$currentProfile"
    _nprofileLoadProfile "$currentProfile"
}

_nprofileCurrent() {
    echo "$N_PROFILE"
}

_nprofilePrintCurrentProfile() {
    local currentProfile="$(_nprofileCurrent)"
    if [[ "$currentProfile" != "" ]]; then
        echo "$currentProfile"
    else
        echo "No current profile loaded."
    fi
}

_nprofileLoadNewProfile() {
    local currentProfile="$(_nprofileCurrent)"
    if [[ "$currentProfile" != "" ]]; then
        _nprofileUnloadProfile "$currentProfile"
    fi

    local newProfile="${1-$currentProfile}"
    _nprofileLoadProfile "$newProfile"
}

_nprofileUsage() {
    echo "Usage:"
    echo "$_nprofileExportAs"
    echo "    Manage development profile on shell."
    echo "[Options]"
    echo "    <profile>"
    echo "        Load the provided profile."
    echo "    -c"
    echo "        Display the current profile."
    echo "    -u"
    echo "        Unload the current profile."
    echo "    -r"
    echo "        Reload the current profile."
    echo "    -h"
    echo "        Show this message."
}

_nprofile() {
    local input="$1"

    if [[ "$input" == "-h" ]]; then
        _nprofileUsage
        return $?
    fi

    if [[ "$input" == "-c" ]]; then
        _nprofilePrintCurrentProfile
        return $?
    fi

    if [[ "$input" == "-u" ]]; then
        _nprofileUnloadCurrentProfile
        return $?
    fi

    if [[ "$input" == "-r" ]]; then
        _nprofileReloadCurrentProfile
        return $?
    fi

    if [[ "$input" != "" ]]; then
        _nprofileLoadNewProfile "$input"
        return $?
    fi

    echo "[ERROR] Wrong usage!"
    _nprofileUsage
    return 1
}

_nprofileInit

alias $_nprofileExportAs="_nprofile"

_nLog "Use '$_nprofileExportAs <profile>' to setup/switch profile."
_nLog "Use '$_nprofileExportAs -h' to know more about this command."
