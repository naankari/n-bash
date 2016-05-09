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
#    N_SHELL_PROFILE_FILE
#        Required: False
#        Default Value: Valid value will be picked from $N_OPTIONS/shell-profile-files
#    N_OPTIONS
#        Required: True



_nprofileExecutableFilePrefix=${N_PROFILE_EXECUTABLE_FILE_PREFIX-"$N_HOME/profile-"}
_nprofileShellProfileFileOptions="$N_OPTIONS/shell-profile-files"
_nprofileTempInputFile="$N_HOME/.n-profile-temp"

_nprofileFindProfile() {
    if [[ -f $_nprofileTempInputFile ]]; then
        profile=$(_nReadEffectiveLine "$_nprofileTempInputFile")
        echo "$profile"
        rm "$_nprofileTempInputFile"
        return
    fi

    echo "$N_PROFILE"
}

_nprofileReset() {
    if [[ "$_N_PROFILE_ORIG" != "" ]]; then
        origProfile=$_N_PROFILE_ORIG
        for i in $(env | sed 's/=.*//') ; do
            if [[ $i != "PATH" ]]; then
                unset "$i"
            fi
        done
        for line in $origProfile; do
            name=$(echo $line | sed 's/=.*//')
            value=$(echo $line | sed 's/.*=//')
            export $name="$value"
        done
        export _N_PROFILE_ORIG="$origProfile"
    else
        export _N_PROFILE_ORIG=$(env)
    fi
}

_nprofileLoad() {
    profile=$(_nprofileFindProfile)

    export N_PROFILE="none"

    if [[ $profile = "" || $profile = "none" ]]; then
        _nLog "Not setting up any profile."
        return
    fi

    _nLog "Setting up profile for $profile ..."
    profileFile="${_nprofileExecutableFilePrefix}${profile}"
    if [[ ! -f $profileFile ]]; then
        _nError "Source file $profileFile does not exists."
    else
        source "$profileFile"
        _nLog "Profile setup done."
        export N_PROFILE="$profile"
    fi
}

_nprofileReinit() {
    shellProfileFile=$(_nprofileiFindShellProfileFile)

    if [[ $shellProfileFile = "" ]]; then
        echo "Please setup N_SHELL_PROFILE_FILE environment variable as the location of your shell profile file. eg: '\$HOME/.profile' or '\$HOME/.bashrc' or whatever."
        return 1
    fi

    if [[ -f $_nprofileTempInputFile ]]; then
        rm "$_nprofileTempInputFile"
    fi

    profile="${1-$N_PROFILE}"

    if [[ $profile != "" && $profile != "default" ]]; then
        echo "$profile" > "$_nprofileTempInputFile"
    fi

    echo "Executing main profile $shellProfileFile ..."
    source "$shellProfileFile"
}

_nprofileiFindShellProfileFile() {
    if [[ "$N_SHELL_PROFILE_FILE" != "" && -f $N_SHELL_PROFILE_FILE ]]; then
        echo "$N_SHELL_PROFILE_FILE"
        return
    fi

    _nFindFirstFileThatExists "$_nprofileShellProfileFileOptions"
}

#_nprofileReset
_nprofileLoad

alias reinit="_nprofileReinit"
