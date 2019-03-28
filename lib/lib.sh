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

_nSourceIf() {
   local aPath=$(_nIndirect "$1")
    if [[ -f $aPath ]]; then
        _nLogOrEcho "Sourcing from file $aPath ..."
        _nLogOrEcho "----- SOURCE BEGIN ----"
        source $aPath
        _nLogOrEcho "----- SOURCE END -----"
    else
        _nWarnOrEcho "File $aPath could not be sourced as it does not exist!"
    fi
}

_nIndirect() {
    local aPath="$1"
    aPath=${aPath/\~/$HOME}
    eval "aPath=\"$aPath\""
    echo "$aPath"
}

_nAbsolutePath() {
    local aPath="$1"

    if [[ "$aPath" == "" ]]; then
        return
    fi

    aPath=$(_nIndirect "$aPath")

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

_nReadEffectiveLines() {
    local aPath=$(_nIndirect "$1")
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
        _nIndirect "$line"
    done
}

_nFindFirstFileThatExists() {
    for option in `_nReadEffectivePaths "$1"`; do
        if [[ -f $option ]]; then
            echo "$option"
            return
        fi
    done
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

_nLibDiagnostics() {
    _nTestCaseConversion
}

_nTestCaseConversion() {
    if [[ $(_nToUpper "abc") != "ABC" ]]; then
        _nWarn "Could not convert to uppercase. Case insensitive things may not work!"
    fi
}
