#!/bin/bash


# Environment
#   N_HOME
#        Required: True
#    N_PATH_SOURCE_FILE
#        Required: False
#        Default Value: $N_HOME/path
#    N_PATH_EXPORT_AS
#        Required: False
#        Default Value: addPath
#   N_TEMPLATES
#       Required: False
#       Default Value: $N_HOME/templates


_npathSourceFile="${N_PATH_SOURCE_FILE-$N_HOME/path}"
_npathExportAs="${N_PATH_EXPORT_AS-addPath}"
_npathSourceFileTemplate="${N_TEMPLATES-$N_HOME/templates}/path"

_npathLoad() {
    if [[ "$_N_PATH_ORIG" != "" ]]; then
        export PATH="$_N_PATH_ORIG"
    fi

    if [[ "$_npathSourceFile" == "" ]]; then
        return
    fi

    if [[ ! -f $_npathSourceFile ]]; then
        _nWarn "Did not find $_npathSourceFile to source path information."
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

    if [[ "$_npathSourceFile" == "" ]]; then
        return
    fi

    echo "Saving new path entry $path in source file $_npathSourceFile ..."

    if [[ ! -f $_npathSourceFile ]]; then
        echo "Did not find file $_npathSourceFile!"
        echo "Enter 'y' or 'yes' to create one and continue:"
        read input
        input=$(_nToLower "$input")
        if [[ "$input" == "y" || "$input" == "yes" ]]; then
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

_npathLoad

alias $_npathExportAs="_npathAppendPath"

_nLog "Use '$_npathExportAs .|<directory name>' to add the current or specific directory to the path."
