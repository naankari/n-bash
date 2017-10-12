#!/bin/bash


# Environment
#   N_LOCAL
#        Required: True
#   N_TEMPLATES_DIR
#       Required: True
#    N_PATH_SOURCE_FILE
#        Required: False
#        Default Value: $N_LOCAL/path
#    N_PATH_EXPORT_AS
#        Required: False
#        Default Value: "path"

_npathSourceFile="$(_nAbsolutePath "${N_PATH_SOURCE_FILE-$N_LOCAL/path}")"
_npathSourceFileTemplate="$(_nAbsolutePath "$N_TEMPLATES_DIR/path")"
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

    paths=$(_nReadEffectiveLines "$_npathSourceFile")
    for path in $paths; do
        PATH="$path:$PATH"
    done

    export PATH

    _nLog "Sourcing path info done."
}

_npathAppendPath() {
    local path="$1"

    if [[ "$path" == "" ]]; then
        path="."
    fi

    path=$(_nAbsolutePath "$path")

    echo "Adding $path in PATH ..."
    echo "Enter 'y' or 'yes' to confirm:"

    local input
    read input
    input=$(_nToLower "$input")
    if [[ "$input" != "y" && "$input" != "yes" ]]; then
        echo "Exiting."
        return
    fi

    export PATH="$path:$PATH"

    echo "Saving new path entry $path in source file $_npathSourceFile ..."

    if [[ ! -f $_npathSourceFile ]]; then
        echo "Did not find file $_npathSourceFile!"
        echo "Enter 'y' or 'yes' to create one and continue:"
        read input
        input=$(_nToLower "$input")
        if [[ "$input" == "y" || "$input" == "yes" ]]; then
            _nEnsureParentDirectoryExists "$_npathSourceFile"
            cp "$_npathSourceFileTemplate" "$_npathSourceFile"
            echo "Created file $_npathSourceFile to source path information."
        else
            echo "Exiting."
            return
        fi
    else
        exits=$(cat "$_npathSourceFile" | grep -i "^$path$" | wc -l)
        if [[ $exits -gt 0 ]]; then
            echo "$path already exists in source file $_npathSourceFile."
            return
        fi
    fi

    echo "$path" >> "$_npathSourceFile"
    echo "Saved path entry."
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
    echo "        Show this message"
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


