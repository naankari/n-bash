#!/bin/bash

# Profile
#	N_HOME
#		Required: True
#	N_PROFILE
#		Required: False
#		Default Value: "none"
#	N_PROFILE_EXECUTABLE_FILE_PREFIX
# 		Required: False
#		Default Value: "$HOME/.profile-"
#	N_PROFILE_MAIN_EXECUTABLE_FILE
#		Required: False
#		Default Value: "$HOME/.profile" or "$HOME/.bashrc"; if exists



_nprofileExecutableFilePrefix=${N_PROFILE_EXECUTABLE_FILE_PREFIX-"$HOME/.profile-"}

_nprofileTempInputFile="$N_HOME/.n-profile-temp"

_nprofileFindProfile() {
	if [[ -f $_nprofileTempInputFile ]]; then
		profile=$(_nReadEffectiveLine $_nprofileTempInputFile)
		echo $profile
		rm $_nprofileTempInputFile
		return
	fi

	echo "$N_PROFILE"
}

_nprofileReset() {
	if [[ "$_N_PROFILE_ORIG" != "" ]]; then
        	origProfile=$_N_PROFILE_ORIG
        	for i in `env | sed 's/=.*//'` ; do
                	if [[ $i != "PATH" ]]; then
                        	unset $i
                	fi
        	done
        	for line in $origProfile; do
                	name=`echo $line | sed 's/=.*//'`
                	value=`echo $line | sed 's/.*=//'`
                	export $name=$value
        	done
        	export _N_PROFILE_ORIG=$origProfile
	else
        	export _N_PROFILE_ORIG=`env`
	fi
}

_nprofileLoad() {
	profile=$(_nprofileFindProfile)
	
	export N_PROFILE="none"
	
	if [[ $profile = "" || $profile = "none" ]]; then
		echo "Not setting up any profile."
		return
	fi
	
	echo "Setting up profile for $profile ..."
	profileFile="${_nprofileExecutableFilePrefix}${profile}"
	if [[ ! -f $profileFile ]]; then
		echo "Source file $profileFile does not exists."
	else
		source $profileFile
		eval $profile
		echo "Profile setup done."
		export N_PROFILE=$profile
	fi
}

_nprofileReinit() {
	executableFile=$(_nprofileiFindMainExecutableFile)
	
	if [[ $executableFile = "" ]]; then
		echo "Please setup N_PROFILE_MAIN_EXECUTABLE_FILE environment variable to correct file path. eg: '\$HOME/.profile' or '\$HOME/.bashrc' or whatever."
                return 1
	fi

	if [[ -f $_nprofileTempInputFile ]]; then
		rm $_nprofileTempInputFile
	fi

	profile="${1-$N_PROFILE}"

	if [[ $profile != "" && $profile != "default" ]]; then
		echo "$profile" > $_nprofileTempInputFile
	fi
	
	echo "Executing main profile $executableFile ..."	
	source $executableFile
}

_nprofileiFindMainExecutableFile() {
	if [[ "$N_PROFILE_MAIN_EXECUTABLE_FILE" != "" && -f $N_PROFILE_MAIN_EXECUTABLE_FILE ]]; then
		echo $N_PROFILE_MAIN_EXECUTABLE_FILE
		return
	fi

	executableFiles="$HOME/.profile:$HOME/.bashrc"
	IFS=':' read -ra executableFilesArray <<< "$executableFiles"
	for executableFile in "${executableFilesArray[@]}"; do
		if [[ -f $executableFile ]]; then
			echo $executableFile
			break
		fi
	done
}

_nprofileReset
_nprofileLoad

alias reinit="_nprofileReinit"

