#!/bin/bash


# Environment
#   N_CONFIG_DIR
#       Required: True
#   N_SOUND_CURRENT_OUTPUT_CHANNEL_FILE
#       Required: False
#       Default Value: "$N_CONFIG_DIR/sound-current-output-channel"
#   N_SOUND_EXPORT_AS
#        Required: False
#        Default Value: "sound"

_nsoundCurrentOutputChannelFile="$(_nAbsolutePath "${N_SOUND_CURRENT_CHANNEL_OUTPUT_FILE-$N_CONFIG_DIR/sound-current-output-channel}")"
_nsoundExportAs="${N_SOUND_EXPORT_AS-sound}"

_nsoundSpeakers() {
    _nLogOrEcho "Setting sound output channel to speakers ..."

    amixer set Headphone 0
    amixer set Front 100

    _nEnsureParentDirectoryExists "$_nsoundCurrentOutputChannelFile"
    echo "speakers" > "$_nsoundCurrentOutputChannelFile"
}

_nsoundHeadphones() {
    _nLogOrEcho "Setting sound output channel to headphones ..."

    amixer set Front 0
    amixer set Headphone 100

    _nEnsureParentDirectoryExists "$_nsoundCurrentOutputChannelFile"
    echo "headphones" > "$_nsoundCurrentOutputChannelFile"
}

_nsoundInit() {
    local currentOutputChannel="$(_nsoundCurrentOutputChannel)"

    if [[ "$currentOutputChannel" == "speakers" ]]; then
        _nsoundSpeakers
        return $?
    fi

    if [[ "$currentOutputChannel" == "headphones" ]]; then
        _nsoundHeadphones
        return $?
    fi

    if [[ "$currentOutputChannel" != "" ]]; then
        _nWarn "Could not set output to unknown channel $currentOutputChannel!"
        return
    fi
}

_nsoundToggleOutputChannel() {
    local currentOutputChannel="$(_nsoundCurrentOutputChannel)"

    if [[ "$currentOutputChannel" == "speakers" ]]; then
        _nsoundHeadphones
        return $?
    fi
    if [[ "$currentOutputChannel" == "headphones" ]]; then
        _nsoundSpeakers
        return $?
    fi
    _nsoundHeadphones
}

_nsoundCurrentOutputChannel() {
    if [[ ! -f "$_nsoundCurrentOutputChannelFile" ]]; then
        return 
    fi

    local currentOutputChannel=$(cat "$_nsoundCurrentOutputChannelFile")
    if [[ "$currentOutputChannel" == "speakers" ]]; then
        echo "speakers"
        return
    fi
    if [[ "$currentOutputChannel" == "headphones" ]]; then
        echo "headphones"
        return
    fi
}

_nsoundUsage() {
    echo "Usage:"
    echo "$_nsoundExportAs"
    echo "    Settings for the sound."
    echo "[Options]"
    echo "    toggle"
    echo "        Toggle the sound output channel between speakers and headphones."
    echo "    speakers"
    echo "        Set sound output channel to speakers."
    echo "    headphones"
    echo "        Set sound output channel to headphones."
    echo "    --current"
    echo "        Display current output channel."
    echo "    -?"
    echo "        Show this message."
}

_nsound() {
    local input="$1"

    if [[ "$input" == "toggle" ]]; then
        _nsoundToggleOutputChannel
        return $?
    fi

    if [[ "$input" == "--current" ]]; then
        _nsoundCurrentOutputChannel
        return $?
    fi

    if [[ "$input" == "speakers" ]]; then
        _nsoundSpeakers
        return $?
    fi

    if [[ "$input" == "headphones" ]]; then
        _nsoundHeadphones
        return $?
    fi

    if [[ "$input" == "-?" ]]; then
        _nsoundUsage
        return $?
    fi

    echo "[ERROR] Wrong usage!"
    _nsoundUsage
    return 1
}

_nsoundInit

alias $_nsoundExportAs="_nsound"

_nLog "Use '$_nsoundExportAs speakers|headphones' to toggle between speakers and headphones."
_nLog "Use '$_nsoundExportAs -?' to know more about this command."

