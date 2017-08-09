#!/bin/bash


# Environment
#   N_HOME
#       Required: True
#   N_PROMPT_HOST_FILE
#       Required: False
#       Default Value: $N_HOME/hostname
#   N_OPTIONS
#       Required: False
#       Default Value: $N_HOME/options
#   N_PROMPT_GIT_PROMPT_FILE
#       Required: False
#       Default Value: Valid value will be picked from $N_OPTIONS/git-prompt-files


_npromptHostnameFile="${N_PROMPT_HOST_FILE-$N_HOME/hostname}"
_npromptGitPromptFile="$N_PROMPT_GIT_PROMPT_FILE"
_npromptGitPromptFileOptions="${N_OPTIONS-$N_HOME/options}/git-prompt-files"

__git_ps1() {
    echo ""
}

_npromptCurrentProfile_ps1() {
    echo "${N_PROFILE-none}"
}

_npromptCurrentHostname_ps1() {
    local host=""
    if [[ -f $_npromptHostnameFile ]]; then
        host=$(_nReadEffectiveLine "$_npromptHostnameFile")
    else
        host="$(hostname)"
    fi
    echo "$host"
}

_npromptSourceGitPrompt() {
    if [[ "$_npromptGitPromptFile" != "" ]]; then
        if [[ ! -f $_npromptGitPromptFile ]]; then
            _nError "Could not find git promot file $_npromptGitPromptFile."
            return
        fi
        source $_npromptGitPromptFile
        return
    fi

    local gitPromotFileOption=$(_nFindFirstFileThatExists "$_npromptGitPromptFileOptions")
    if [[ "$gitPromotFileOption" != "" ]]; then
        source $gitPromotFileOption
    else
        _nWarn "Could not file any git prompt file."
    fi
}

_npromptLoad() {
    if [[ ! -f $_npromptHostnameFile ]]; then
        _nWarn "Could not find hostname file $_npromptHostnameFile."
    fi
    _npromptSourceGitPrompt

    PS1="\`if [[ \$? == 0 ]]; then echo '\[\033[1;32m\][^_^]'; else echo '\[\033[1;31m\][O_O]'; fi\`\
 \[\033[0;34m\][\$(_npromptCurrentProfile_ps1)]\
 \[\033[34m\]\u\
\[\033[0m\]@\
\[\033[34m\]\$(_npromptCurrentHostname_ps1)\
 \[\033[0m\]\D{%a %Y-%m-%d}::\t\
 \[\033[34m\][\w]\
\[\033[0m\]\$(__git_ps1)\
\n\
\[\033[1;34m\]$>\
\[\033[0m\]"
}

_npromptLoad
