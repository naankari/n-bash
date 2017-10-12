#!/bin/bash


# Environment
#   N_DIR_HISTORY_SIZE
#       Required: False
#       Default Value: 10
#   N_DIR_EXPORT_AS
#       Required: False
#       Default Value: "dh"

_ndhSize=${N_DIR_HISTORY_SIZE-10}
_ndhExportAs="${N_DIR_EXPORT_AS-dh}"

_ndhHistory=()

_ndhUpdateHistory() {
    local cwd="$PWD"
    local nextValue="$cwd"
    for index in $(seq 0 $(expr $_ndhSize - 1)); do
        local oldValue="${_ndhHistory[$index]}"
        _ndhHistory[$index]="$nextValue"
        if [[ "$oldValue" == "" || "$oldValue" == "$cwd" ]]; then
            break
        fi
        nextValue="$oldValue"
    done
}

_ndhInit() {
    export PROMPT_COMMAND=_ndhUpdateHistory
}

_ndhPrintHistory() {
    local count="${#_ndhHistory[@]}"
    if [[ $count -eq 0 ]]; then
        echo "Directory history is empty."
        return
    fi

    echo "Available history:"

    for index in $(seq 0 $(expr $_ndhSize - 1)); do
        local dirName="${_ndhHistory[$index]}"
        if [[ "$dirName" == "" ]]; then
            break
        fi

        local isCurrent=""
        if [[ "$PWD" == "$dirName" ]]; then
            isCurrent="(*)"
        fi
        echo "[$index]: $dirName $isCurrent"
    done

    if [[ "$1" == "-showPrompt" ]]; then
        _ndhPromptForIndex
    fi
}

_ndhGoToIndex() {
    if [[ $# -ne 1 ]]; then
        echo "[ERROR] Missing input!"
        return 1
    fi

    local index="$1"

    if ! [[ $index =~ ^[0-9]+$ ]]; then
        echo "[ERROR] Invalid input!"
        return 2
    fi

    if [[ $index -lt 0 ]]; then
        echo "[ERROR] Invalid input!"
        return 3
    fi

    local dirName="${_ndhHistory[$index]}"

    if [[ "$dirName" == "" ]]; then
        echo "[ERROR] This history record does not exist!"
        return 3
    fi

    echo "Changing dir to: $dirName"
    cd "$dirName"
}

_ndhPromptForIndex() {
    echo "Go To: (Enter to stay here): "
    local input
    read input

    if [[ "$input" == "" ]]; then
        return
    fi

    _ndhGoToIndex "$input"

    if [[ $? -ne 0 ]]; then
        _ndhPromptForIndex
    fi
}

_ndhCleanHistory() {
    _ndhHistory=()
    _ndhUpdateHistory
    echo "History cleaned."
}

_ndhPrintUsage() {
    echo "Usage:"
    echo "$_ndhExportAs"
    echo "          Show the history and prompt for the input."
    echo "[Optional]"
    echo "    -c"
    echo "          Clean the history."
    echo "    <num>"
    echo "          Change directory to the given index in history."
    echo "    -i"
    echo "          Show the history alone; do not prompt for the input."
    echo "    -?"
    echo "          Show this message."
}

_ndh() {
    if [[ $# -ne 1 ]]; then
        _ndhPrintHistory -showPrompt
        return $?
    fi

    local input="$1"

    if [[ $input == "-i" ]]; then
        _ndhPrintHistory
        return $?
    fi

    if [[ $input == "-c" ]]; then
        _ndhCleanHistory
        return $?
    fi

    if [[ $input == "-?" ]]; then
        _ndhPrintUsage
        return $?
    fi

    if [[ $input =~ ^[0-9]+$ ]]; then
        _ndhGoToIndex $input
        return $?
    fi

    echo "[ERROR] Wrong usage!"
    _ndhPrintUsage
    return 1
}

_ndhInit

alias $_ndhExportAs="_ndh"

_nLog "Use '$_ndhExportAs -?' to know more about directory hostory command."

