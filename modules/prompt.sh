#!/bin/bash


# Environment
#   N_CURRENT_SHELL
#       Required: True
#   N_CONFIG_DIR
#       Required: True
#   N_OPTIONS_DIR
#       Required: True
#   N_PROMPT_HOST_FILE
#       Required: False
#       Default Value: "$N_CONFIG_DIR/hostname"
#   N_PROMPT_GIT_PROMPT_FILE
#       Required: False
#       Default Value: Valid value will be picked from options file "$N_OPTIONS_DIR/git-prompt-files"

_npromptHostnameFile="$(_nToAbsolutePath "${N_PROMPT_HOST_FILE-$N_CONFIG_DIR/hostname}")"
_npromptGitPromptFile="$(_nToAbsolutePath "$N_PROMPT_GIT_PROMPT_FILE")"
_npromptGitPromptFileOptions="$(_nToAbsolutePath "$N_OPTIONS_DIR/git-prompt-files")"

_npromptErrorColor="\e[1;31m"
_npromptSuccessColor="\e[1;32m"
_npromptHeighlightColor="\e[0;34m"
_npromptDefaultColor="\e[0m"

_nPromptEscapeBash() {
    local toEscape="$1"
    echo "\[${toEscape}\]"
}

_npromptGitStatusForPrompt() {
    if [[ $(_nDoesFunctionExist "__gitForPrompt") == 1 ]]; then
        __git_ps1
    fi
}

_npromptCurrentProfileForPrompt() {
    echo "${N_PROFILE-none}"
}

_npromptCurrentUserForPrompt() {
    if [[ "$N_CURRENT_SHELL" == "bash" ]]; then
        echo "\u"
    elif [[ "$N_CURRENT_SHELL" == "zsh" ]]; then
        echo "%n"
    fi
}

_npromptCurrentHostForPrompt() {
    if [[ -f $_npromptHostnameFile ]]; then
        _nReadEffectiveLine "$_npromptHostnameFile"
        return;
    fi
    if [[ "$N_CURRENT_SHELL" == "bash" ]]; then
        echo "\h"
    elif [[ "$N_CURRENT_SHELL" == "zsh" ]]; then
        echo "%m"
    fi
}

_npromptSourceGitPrompt() {
    if [[ "$_npromptGitPromptFile" != "" ]]; then
        if [[ ! -f $_npromptGitPromptFile ]]; then
            _nError "Could not find git prompt file $_npromptGitPromptFile!"
            return
        fi
        source $_npromptGitPromptFile
        return
    fi

    local gitPromptFileOption=$(_nFindFirstFileThatExists "$_npromptGitPromptFileOptions")
    if [[ "$gitPromptFileOption" != "" ]]; then
        source $gitPromptFileOption
    else
        _nWarn "Could not find any git prompt files from options!"
    fi
}


_npromptInit() {
    if [[ ! -f $_npromptHostnameFile ]]; then
        _nWarn "Could not find hostname file $_npromptHostnameFile!"
    fi
    _npromptSourceGitPrompt

    local escapeFn() {
        echo "$1"
    }

    if [[ "$N_CURRENT_SHELL" == "bash" ]]; then
        escapeFn=_npromptEscapeBash
    fi

    local currentUser=$(_npromptCurrentUserForPrompt)
    local currentHost=$(_npromptCurrentHostForPrompt)

    PS1="\`if [[ \$? == 0 ]]; then echo '$(escapeFn $_npromptSuccessColor)[^_^]'; else echo '$(escapeFn $_npromptErrorColor)[0_0]'; fi\`\
$(escapeFn $_npromptHeighlightColor) [$(_npromptCurrentProfileForPrompt)] \
$currentUser\
$(escapeFn $_npromptDefaultColor)@\
$(escapeFn $_npromptHeighlightColor)$currentHost\
$(escapeFn $_npromptDefaultColor)$(_npromptGitStatusForPrompt)
$(escapeFn $_npromptHeighlightColor)\$>$(escapeFn $_npromptDefaultColor)"


    echo $PS1

    PS9="\`if [[ \$? == 0 ]]; then echo '\[\033[1;32m\][^_^]'; else echo '\[\033[1;31m\][O_O]'; fi\`\
 \[\033[0;34m\][\$(_npromptCurrentProfileForPrompt)]\
 \[\033[34m\]\u\
\[\033[0m\]@\
\[\033[34m\]\$(_npromptCurrentHostnameForPrompt)\
 \[\033[0m\]\D{%a %Y-%m-%d}::\t\
 \[\033[34m\][\w]\
\[\033[0m\]\$(__gitForPrompt)\
\n\
\[\033[1;34m\]$>\
\[\033[0m\]"

}

_npromptInit
