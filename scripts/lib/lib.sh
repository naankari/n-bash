#!/bin/bash



_nLog() {
    logLevel=$(_nToLower "$N_LOG_LEVEL")
    if [[ $logLevel = "verbose" ]]; then
        echo "NJS:LOG: $1"
    fi
}

_nWarn() {
    logLevel=$(_nToLower "$N_LOG_LEVEL")
    if [[ $logLevel = "verbose" || $logLevel = "warn" ]]; then
        echo "NJS:WARN: $1"
    fi
}

_nError() {
    logLevel=$(_nToLower "$N_LOG_LEVEL")
    if [[ $logLevel = "verbose" || $logLevel = "warn" || $logLevel = "error" ]]; then
        echo "NJS:ERROR: $1"
    fi
}

_nSourceIf() {
    path=$(_nIndirect "$1")
    if [[ -f $path ]]; then
        source "$path"
    else
        _nError "File $path could not be sourced."
    fi
}

_nIndirect() {
    path="$1"
    path=${path/\~/$HOME}
    eval "path=\"$path\""
    echo "$path"
}

_nReadEffectiveLines() {
    path=$(_nIndirect "$1")
    if [[ ! -f $path ]]; then
        echo ""
        return
    fi
    lines=$(cat "$path" | sed -e 's/^\s*//;s/\s*$//' | grep -iv "^[ \t]*$" | grep -iv "^[ \t]*#.*$")
    for line in $lines; do
        _nIndirect "$line"
    done
}

_nReadEffectiveLine() {
    content=$(_nReadEffectiveLines "$1")
    content=$(echo "$content" | head -1)
    echo "$content"
}

_nFindFirstFileThatExists() {
    options=$(_nReadEffectiveLines "$1")

    for option in $options; do
        if [[ -f $option ]]; then
            echo "$option"
            return
        fi
    done
}

_nIsInstalled() {
    location=$(type -p "$1")
    if [[ $location != "" ]]; then
        echo "yes"
    fi
}

_nIsBash4() {
    version="$BASH_VERSION"
    if [[ version == 4.* ]]; then
        echo "yes"
    fi
}

_nToUpper() {
    value="$1"

    isBash4=$(_nIsBash4)
    if [[ isBash4 = "yes" ]]; then
        value=${value^^}
        echo "$value"
        return
    fi

    awkInstalled=$(_nIsInstalled "awk")
    if [[ $awkInstalled = "yes" ]]; then
        value=$(echo "$value" | awk '{ print toupper($0) }')
        echo "$value"
        return
    fi

    echo "$value"
}

_nToLower() {
    value="$1"

    isBash4=$(_nIsBash4)
    if [[ isBash4 = "yes" ]]; then
        value=${value,,}
        echo "$value"
        return
    fi

    awkInstalled=$(_nIsInstalled "awk")
    if [[ $awkInstalled = "yes" ]]; then
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
        _nWarn "Could not convert to uppercase. Case insensitive things may not work."
    fi
}
