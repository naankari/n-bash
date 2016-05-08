#!/bin/bash

# Environment
#       N_HOME
#               Required: True
#       N_GIT_PROMPT_FILE
#               Required: False
#               Default Value: Valid value will be picked from $N_OPTIONS/git-prompt-files
#       N_OPTIONS
#               Required: True



_npromptHostnameInputFile="$N_HOME/hostname"
_npromptGitPromptFileOptions="$N_OPTIONS/git-prompt-files"

__git_ps1() {
    echo ""
}

_npromptFindGitPrompt() {
    if [[ "$N_GIT_PROMPT_FILE" != "" && -f $N_GIT_PROMPT_FILE ]]; then
        echo "$N_GIT_PROMPT_FILE"
        return
    fi

    _nFindFirstFileThatExists "$_npromptGitPromptFileOptions"
}

_npromptLoad() {        
    if [[ -f $_npromptHostnameInputFile ]]; then
        nhost=$(_nReadEffectiveLine "$_npromptHostnameInputFile")
    else
        _nWarn "Could not find hostname file $_npromptHostnameInputFile"
        nhost=$(hostname)
    fi

    gitPromptFile=$(_nFindFirstFileThatExists "$_npromptGitPromptFileOptions")
    if [[ $gitPromptFile != "" ]]; then
        _nLog "Sourcing git prompt file $gitPromptFile"
        source "$gitPromptFile"
    else
        _nWarn "Could not file any git prompt file."
    fi

    profile=${N_PROFILE-none}
    PS1="\`if [[ \$? = 0 ]]; then echo '\[\033[1;32m\][^_^]'; else echo '\[\033[1;31m\][O_O]'; fi\`\
 \[\033[34m\][\$profile]\
 \[\033[34m\]\u\
\[\033[0m\]@\
\[\033[34m\]\$nhost\
 \[\033[0m\]\D{%a %Y-%m-%d}::\t\
 \[\033[34m\][\w]\
\[\033[0m\]\$(__git_ps1)\
\n\
\[\033[1;34m\]$>\
\[\033[0m\]"
}

_npromptLoad

