#!/bin/bash


# Environment
#   N_CONFIG_DIR
#        Required: True
#   N_DEFAULTS_DIR
#       Required: True
#    N_PATH_SOURCE_FILE
#        Required: False
#        Default Value: $N_CONFIG_DIR/path
#    N_PATH_EXPORT_AS
#        Required: False
#        Default Value: "path"

_npathSourceFile="$(_nAbsolutePath "${N_PATH_SOURCE_FILE-$N_CONFIG_DIR/path}")"
_npathSourceFileDefault="$(_nAbsolutePath "$N_DEFAULTS_DIR/path")"
_npathExportAs="${N_PATH_EXPORT_AS-path}"

_npathInit() {
    if [[ "$_N_PATH_ORIG" != "" ]]; then
        export PATH="$_N_PATH_ORIG"
    fi

    if [[ ! -f $_npathSourceFile ]]; then
        _nWarn "Did not find $_npathSourceFile to source path information!"
        return
    fi

    _nLog "Sourcing path info from $_npathSourceFile ..."

    export _N_PATH_ORIG="$PATH"

    for aPath in `_nReadEffectivePaths "$_npathSourceFile"`; do
        PATH="$aPath:$PATH"
    done

    export PATH

    _nLog "Sourcing path info done."
}

_npathTryToCreatePathFileIfDoesNotExist() {
    if [[ -f $_npathSourceFile ]]; then
        return
    fi

    echo "Did not find file $_npathSourceFile!"
    echo "Enter 'y' or 'yes' to create one and continue:"
    local input
    read input
    input="$(_nToLower "$input")"
    if [[ "$input" != "y" && "$input" != "yes" ]]; then
        echo "Exiting."
        return
    fi

    _nEnsureParentDirectoryExists "$_npathSourceFile"

    if [[ ! -f $_npathSourceFileDefault ]]; then
        echo "Default file $_npathSourceFileDefault does not exist. Creating empty file."
        echo "" > "$_npathSourceFile"
    else
        echo "Copying from default file $_npathSourceFileDefault ..."
        cp "$_npathSourceFileDefault" "$_npathSourceFile"
    fi

    echo "Created file $_npathSourceFile to source path information."
}

_npathAppendPath() {
    local aPath="$1"

    if [[ "$aPath" == "" ]]; then
       aPath="."
    fi

    aPath=$(_nAbsolutePath "$aPath")

    echo "Adding $aPath in PATH ..."
    echo "Enter 'n' or 'no' to cancel:"

    local input
    read input
    input=$(_nToLower "$input")
    if [[ "$input" == "n" || "$input" == "no" ]]; then
        echo "Exiting."
        return
    fi

    export PATH="$aPath:$PATH"

    echo "Saving new path entry $aPath in source file $_npathSourceFile ..."

    echo "Enter 'n' or 'no' to cancel:"
    read input
    input=$(_nToLower "$input")
    if [[ "$input" == "n" || "$input" == "no" ]]; then
        echo "Exiting."
        return
    fi

    _npathTryToCreatePathFileIfDoesNotExist

    if [[ ! -f $_npathSourceFile ]]; then
        return
    fi

    exits=$(cat "$_npathSourceFile" | grep -i "^$aPath$" | wc -l)
    if [[ $exits -gt 0 ]]; then
        echo "$aPath already exists in source file."
        return
    fi

    echo "$aPath" >> "$_npathSourceFile"
    echo "Saved path entry in source file."
}

_npathPrintUsage() {
    echo "Usage:"
    echo "$_npathExportAs"
    echo "    Add directory to the PATH environment."
    echo "[Options]"
    echo "    <directory>"
    echo "        Add provided directory to the PATH environment."
    echo "    <dot>"
    echo "        Add current directory to the PATH environment."
    echo "    <blank>"
    echo "        Add current directory to the PATH environment."
    echo "    -?"
    echo "        Show this message."
}

_npath() {
    local input="$1"

    if [[ "$input" == "-?" ]]; then
        _npathPrintUsage
        return $?
    fi

    _npathAppendPath "$input"
    return $?
}

_npathInit

alias $_npathExportAs="_npath"

_nLog "Use '$_npathExportAs .|<directory name>' to add the current or specific directory to the path."
_nLog "Use '$_npathExportAs -?' to know more about this command."
