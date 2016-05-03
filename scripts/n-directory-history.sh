#!/bin/bash

# Environment
#       N_DIR_HISTORY_SIZE
#               Required: False
#               Default Value: 10



_ndhSize=${N_DIR_HISTORY_SIZE-10}

_ndhHistory=()
_ndhPreviousWorkingDirectory=""

_ndhUpdateHistory() {
    if [[ $_ndhPreviousWorkingDirectory != "" &&  $PWD != $_ndhPreviousWorkingDirectory ]]; then
        currentCount=${#_ndhHistory[@]}
	if [[ $currentCount -gt $_ndhSize ]]; then
		for index in `seq $_ndhSize $currentCount`; do
                unset _ndhHistory[$index-1] #Funny. Unset can not have space in the index calculation.
            done
        fi
        
	nextValue=$_ndhPreviousWorkingDirectory
          
        for index in `seq 1 $_ndhSize`
        do
            oldValue="${_ndhHistory[$index - 1]}"
            
            _ndhHistory[$index - 1]=$nextValue

            if [[ $oldValue == "" || $oldValue == $_ndhPreviousWorkingDirectory ]]; then
                break
            fi
            nextValue=$oldValue
        done
    fi

    _ndhPreviousWorkingDirectory=$PWD
}

_ndhPrintHistory() {
    count=${#_ndhHistory[@]}
    if [[ $count -eq 0 ]]; then
        echo "Directory history is empty"
        return
    fi
    
    echo "Available history:"
    
    for index in `seq 1 $count`; do
        dirName="${_ndhHistory[$index - 1]}"
        if [[ $PWD == $dirName ]]; then
            isCurrent="(*)"
        else
            isCurrent=""
        fi
        echo "[$index]: $dirName $isCurrent"
    done

    if [[ "$1" == "-showPrompt" ]]; then
        _ndhPromptForIndex
    fi
}

_ndhPromptForIndex() {
    echo "Go To <Enter to stay here>: "
    
    read input
    
    if [[ $input == "" ]]; then
        return
    fi
    
    _ndhGoToIndex $input

    if [[ $? -ne 0 ]]; then
        _ndhPromptForIndex
    fi
}

_ndhGoToIndex() {
    if [[ $# -ne 1 ]]; then
        echo "[ERROR] Missing input"
        return 1
    fi

    index="$1"

    if ! [[ $index =~ ^[0-9]+$ ]]; then
        echo "[ERROR] Invalid input"
        return 2
    fi

    if [[ `expr $index - 1` -lt 0 ]]; then
        echo "[ERROR] Invalid input"
        return 3
    fi

    dirName="${_ndhHistory[$index - 1]}"

    if [[ $dirName == "" ]]; then
        echo "[ERROR] This history record does not exist"
        return 3
    fi

    echo "Changing dir to: $dirName"
    cd "$dirName"
}

_ndhCleanHistory() {
    _ndhHistory=()
    echo "History cleaned"
}

_ndhPrintUsage() {
    echo "Usage:"
    echo "$_ndhProgramName"
    echo "          Show the history and prompt for the input"
    echo "[Optional]"
    echo "    -c"
    echo "          Clean the history"
    echo "    <num>"
    echo "          Change directory to the given index in history"
    echo "    -i"
    echo "          Show the history alone; do not prompt for the input"
    echo "    -?"
    echo "          Show this message"
}

_ndh() {
    if [[ $# -ne 1 ]]; then
        _ndhPrintHistory -showPrompt
        return $?
    fi

    input="$1"

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

    echo "Wrong use"
    _ndhPrintUsage
    return 1
}

export PROMPT_COMMAND=_ndhUpdateHistory

_ndhProgramName="dh"
alias dh="_ndh"

