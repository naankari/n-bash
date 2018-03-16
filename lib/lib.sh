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
   local path=$(_nIndirect "$1")
    if [[ -f $path ]]; then
        _nLogOrEcho "Sourcing from file $path ..."
        _nLogOrEcho "----- SOURCE BEGIN ----"
        source $path
        _nLogOrEcho "----- SOURCE END -----"
    else
        _nWarnOrEcho "File $path could not be sourced as it does not exist!"
    fi
}

_nIndirect() {
    local path="$1"
    path=${path/\~/$HOME}
    eval "path=\"$path\""
    echo "$path"
}

_nAbsolutePath() {
    local path="$1"

    if [[ "$path" == "" ]]; then
        return
    fi

    path=$(_nIndirect "$path")

    if [[ "$path" == "." ]]; then
        path="./"
    fi

    local cwd="$PWD/"
    path=${path/\.\//$cwd}

    if [[ "$path" != /* ]]; then
        path="$cwd$path"
    fi

    echo "$path"
}

_nEnsureDirectoryExists() {
    mkdir -p "$1"
}

_nEnsureParentDirectoryExists() {
    local filePath="$1"
    mkdir -p "$(dirname "$filePath")"
}

_nReadEffectiveLines() {
    local path=$(_nIndirect "$1")
    if [[ ! -f $path ]]; then
        echo ""
        return
    fi
    local lines=$(cat "$path" | sed -e 's/^\s*//;s/\s*$//' | grep -iv "^[ \t]*$" | grep -iv "^[ \t]*#.*$")
    for line in $lines; do
        _nIndirect "$line"
    done
}

_nReadEffectiveLine() {
    local content=$(_nReadEffectiveLines "$1")
    content=$(echo "$content" | head -1)
    echo "$content"
}

_nFindFirstFileThatExists() {
    local options=$(_nReadEffectiveLines "$1")

    for option in $options; do
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

