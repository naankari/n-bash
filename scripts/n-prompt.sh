#!/bin/bash

# Environment
#       N_HOME
#               Required: True
#       N_HOSTNAME_INPUT_FILE
#               Required: False
#               Default Value: "$N_HOME/n-hostname"
#       N_GIT_PROMPT
#               Required: False
#               Default Value: Valid value will be picked from $N_HOME/n-options-git-prompt-file



_npromptHostnameInputFile=${N_HOSTNAME_INPUT_FILE-"$N_HOME/n-hostname"}
_npromptGitPromptFileOptions="$N_HOME/n-options-git-prompt-file"

__git_ps1() {
        echo ""
}

_npromptLoad() {        
        if [[ -f $_npromptHostnameInputFile ]]; then
                nhost=$(_nReadEffectiveLine $_npromptHostnameInputFile)
        else
                echo "Could not find hostname file $_npromptHostnameInputFile"
                nhost=`hostname`
        fi

	echo "$_npromptGitPromptFileOptions"

	gitPromptFile=$(_nFindFirstFileThatExists $_npromptGitPromptFileOptions)
	if [[ $gitPromptFile != "" ]]; then
		echo "Sourcing git prompt file $gitPromptFile ..."
		source $gitPromptFile
	else
		echo "Could not file any git prompt file."
	fi

	profile=${N_PROFILE-none}

        PS1="\`if [[ \$? = 0 ]]; then echo '\[\033[1;32m\][^_^]'; else echo '\[\033[1;31m\][O_O]'; fi\`\
 \[\033[1;34m\](\$profile)\
 \[\033[1;34m\]\u@\$nhost\
 \[\033[0m\]\D{%a %Y-%m-%d}::\t\
 \[\033[34m\][\w]\
\[\033[0m\]\$(__git_ps1)\
\n\
\[\033[1;34m\]$>\
\[\033[0m\]"
}

_npromptLoad

