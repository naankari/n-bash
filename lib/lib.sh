#!/bin/bash


# Environment
#   N_LOG_LEVEL
#       Required: False
#       Default Value: <none>
#   N_LOAD_STAGE
#       Required: False
#       Default Value: <none>

_nLog() {
    local logLevel=$(_nToLower "$N_LOG_LEVEL")
    if [[ "$logLevel" == "verbose" ]]; then
        echo "NJS:LOG: $1"
    fi
}

_nWarn() {
    local logLevel=$(_nToLower "$N_LOG_LEVEL")
    if [[ "$logLevel" == "verbose" || "$logLevel" == "warn" ]]; then
        echo "NJS:WARN: $1"
    fi
}

_nError() {
    local logLevel=$(_nToLower "$N_LOG_LEVEL")
    if [[ "$logLevel" == "verbose" || "$logLevel" == "warn" || "$logLevel" == "error" ]]; then
        echo "NJS:ERROR: $1"
    fi
}

_nLogOrEcho() {
    if [[ "$N_LOAD_STAGE" == "runtime" ]]; then
        echo "$1"
        return
    fi

    _nLog "$1"
}

_nWarnOrEcho() {
    if [[ "$N_LOAD_STAGE" == "runtime" ]]; then
        echo "[WARN] $1"
        return
    fi

    _nWarn "$1"
}

_nErrorOrEcho() {
    if [[ "$N_LOAD_STAGE" == "runtime" ]]; then
        echo "[ERROR] $1"
        return
    fi

    _nError "$1"
}

_nEvaluatePath() {
    local aPath="$1"
    aPath=${aPath/\~/$HOME}
    eval "aPath=\"$aPath\""
    echo "$aPath"
}

_nToAbsolutePath() {
    local aPath="$1"

    if [[ "$aPath" == "" ]]; then
        return
    fi

    aPath=$(_nEvaluatePath "$aPath")

    if [[ "$aPath" == "." ]]; then
        aPath="./"
    fi

    local cwd="$PWD/"
    aPath=${aPath/\.\//$cwd}

    if [[ "$aPath" != /* ]]; then
        aPath="$cwd$aPath"
    fi

    echo "$aPath"
}

_nEnsureDirectoryExists() {
    mkdir -p "$1"
}

_nEnsureParentDirectoryExists() {
    local filePath="$1"
    mkdir -p "$(dirname "$filePath")"
}

_nDoesFileExist() {
    local aPath="$(_nEvaluatePath "$1")"
    if [[ -f $aPath ]]; then
        echo 1
    else
        echo 0
    fi
}

_nFindFirstFileThatExists() {
    for option in `_nReadEffectivePaths "$1"`; do
        if [[ -f $option ]]; then
            echo "$option"
            return
        fi
    done
}

_nReadEffectiveLines() {
    local aPath=$(_nEvaluatePath "$1")
    if [[ ! -f $aPath ]]; then
        echo ""
        return
    fi
    local lines=$(cat "$aPath" | sed -e 's/^\s*//;s/\s*$//' | grep -iv "^[ \t]*$" | grep -iv "^[ \t]*#.*$")
    echo $lines
}

_nReadEffectiveLine() {
    local lines=$(_nReadEffectiveLines "$1")
    lines=$(echo "$lines" | head -1)
    echo "$lines"
}

_nReadEffectivePaths() {
    for line in `_nReadEffectiveLines "$1"`; do
        _nEvaluatePath "$line"
    done
}

_nToUpper() {
    local value="$1"

    local isBash4="$(_nIsBash4)"
    if [[ "$isBash4" == "yes" ]]; then
        value=${value^^}
        echo "$value"
        return
    fi

    local awkInstalled=$(_nIsInstalled "awk")
    if [[ "$awkInstalled" == "yes" ]]; then
        value=$(echo "$value" | awk '{ print toupper($0) }')
        echo "$value"
        return
    fi

    echo "$value"
}

_nToLower() {
    local value="$1"

    local isBash4="$(_nIsBash4)"
    if [[ "$isBash4" == "yes" ]]; then
        value=${value,,}
        echo "$value"
        return
    fi

    local awkInstalled=$(_nIsInstalled "awk")
    if [[ "$awkInstalled" == "yes" ]]; then
        value=$(echo "$value" | awk '{ print tolower($0) }')
        echo "$value"
        return
    fi

    echo "$value"
}

_nIndirect() {
    local name="$1"
    export currentShell="$(_nGetCurrentShell)"
    if [[ "$currentShell" == "bash" ]]; then
       echo "${!name}"
    elif [[ "$currentShell" == "zsh" ]]; then
       echo "${(P)name}"
    else
       echo ""
    fi
}

_nSourceIf() {
   local aPath=$(_nEvaluatePath "$1")
    if [[ -f $aPath ]]; then
        _nLogOrEcho "Sourcing from file $aPath ..."
        _nLogOrEcho "----- SOURCE BEGIN ----"
        source $aPath
        _nLogOrEcho "----- SOURCE END -----"
    else
        _nWarnOrEcho "File $aPath could not be sourced as it does not exist!"
    fi
}

_nDoesFunctionExist() {
    declare -f $1 > /dev/null
    local lastStatus=$?
    if [[ $lastStatus == 0 ]]; then
        echo 1
    else
        echo 0
    fi
}

_nIsInstalled() {
    local location=$(type -p "$1")
    if [[ $location != "" ]]; then
        echo "yes"
    fi
}

_nIsBash4() {
    local version="$BASH_VERSION"
    if [[ version == 4.* ]]; then
        echo "yes"
    fi
}

_nGetCurrentShell() {
    if [[ -n "$ZSH_VERSION" ]]; then
       echo "zsh"
    elif [[ -n "$BASH_VERSION" ]]; then
       echo "bash"
    else
       echo "unknown"
    fi
}

_nLibDiagnostics() {
    _nTestCaseConversion
}

_nTestCaseConversion() {
    if [[ $(_nToUpper "abc") != "ABC" ]]; then
        _nWarn "Could not convert to uppercase. Case insensitive things may not work!"
    fi
}
