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

_nsoundCurrentOutputChannelFile="$(_nToAbsolutePath "${N_SOUND_CURRENT_OUTPUT_CHANNEL_FILE-$N_CONFIG_DIR/sound-current-output-channel}")"
_nsoundAvailableOutputChannelsFile="$(_nToAbsolutePath "${N_SOUND_AVAILABLE_OUTPUT_CHANNELS_FILE-$N_CONFIG_DIR/sound-available-output-channels}")"
_nsoundAvailableOutputChannelsFileDefault="$(_nToAbsolutePath "$N_DEFAULTS_DIR/sound-available-output-channels")"
_nsoundExportAs="${N_SOUND_EXPORT_AS-sound}"

_nsoundAvailableOutputChannels=()

_nsoundIsOutputChannelInList() {
    local outputChannel="$1"

    for availableOutputChannel in "${_nsoundAvailableOutputChannels[@]}"; do
        if [[ "$availableOutputChannel" == "$outputChannel" ]]; then
            echo "yes"
            break
        fi
    done
}

_nsoundSetOutputChannel() {
    local outputChannel="$1"
    local amixerOptions="$2"

    _nLogOrEcho "Setting sound output channel to $outputChannel ..."

    local isOutputChannelInList="$(_nsoundIsOutputChannelInList "$outputChannel")"
    if [[ "$isOutputChannelInList" != "yes" ]]; then
        _nErrorOrEcho "Could not find matching channel!"
        return 1
    fi

    local returnStatus=0
    for availableOutputChannel in "${_nsoundAvailableOutputChannels[@]}"; do
        if [[ "$availableOutputChannel" == "$outputChannel" ]]; then
            amixer $amixerOptions set "$availableOutputChannel" 100
            returnStatus=$(expr $returnStatus + $?)
        else
            amixer $amixerOptions set "$availableOutputChannel" 0
            returnStatus=$(expr $returnStatus + $?)
        fi
        _nEnsureParentDirectoryExists "$_nsoundCurrentOutputChannelFile"
        echo "$outputChannel" > "$_nsoundCurrentOutputChannelFile"
    done

    if [[ $returnStatus -ne 0 ]]; then
        _nErrorOrEcho "Some error has occurred with amixer! Maybe wrong channel name!"
    fi
    return $returnStatus
}
_nsoundCurrentOutputChannel() {
    if [[ ! -f "$_nsoundCurrentOutputChannelFile" ]]; then
        return
    fi

    local currentOutputChannel=$(cat "$_nsoundCurrentOutputChannelFile")
    echo "$currentOutputChannel"
}

_nsoundInit() {
    if [[ ! -f $_nsoundAvailableOutputChannelsFile ]]; then
        _nWarn "Could not read available sound output channels file $_nsoundAvailableOutputChannelsFile!"
        if [[ -f $_nsoundAvailableOutputChannelsFileDefault ]]; then
            _nLog "Copying from default file $_nsoundAvailableOutputChannelsFileDefault ..."

            _nEnsureParentDirectoryExists "$_nsoundAvailableOutputChannelsFile"
            cp "$_nsoundAvailableOutputChannelsFileDefault" "$_nsoundAvailableOutputChannelsFile"
        fi
    fi

    for availableOutputChannel in `$(_nReadEffectiveLines "$_nsoundAvailableOutputChannelsFile")`; do
        _nsoundAvailableOutputChannels+=("$availableOutputChannel")
    done

    if [[ "$availableOutputChannels" != "" ]]; then
        _nLog "Found available sound channels: ${_nsoundAvailableOutputChannels[*]}."
    else
        _nWarn "Did not find any available sound channels!"
    fi
    _nLog "Modify file $_nsoundAvailableOutputChannelsFile to correct available sound channels."

    if [[ ! -f "$_nsoundCurrentOutputChannelFile" ]]; then
        _nLog "Did not find current sound output channel file $_nsoundCurrentOutputChannelFile. Skipping setting output channel."
        return
    fi

    local currentOutputChannel="$(_nsoundCurrentOutputChannel)"
    if [[ "$currentOutputChannel" == "" ]]; then
        return
    fi

    _nsoundSetOutputChannel "$currentOutputChannel" "-q"
    return $?
}

_nsoundFindNextOutputChannel() {
    local currentOutputChannel="$(_nsoundCurrentOutputChannel)"
    local firstOutputChannel="${_nsoundAvailableOutputChannels[0]}"

    if [[ "$currentOutputChannel" == "" ]]; then
        echo "$firstOutputChannel"
        return
    fi

    local matchFound=false
    for availableOutputChannel in "${_nsoundAvailableOutputChannels[@]}"; do
        if [[ "$matchFound" == true ]]; then
            echo "$availableOutputChannel"
            return
        fi

        if [[ "$availableOutputChannel" == "$currentOutputChannel" ]]; then
            matchFound=true
        fi
    done

    echo "$firstOutputChannel"
    return
}

_nsoundToggleOutputChannel() {
    local nextOutputChannel="$(_nsoundFindNextOutputChannel)"

    if [[ "$nextOutputChannel" == "" ]]; then
        return
    fi

    _nsoundSetOutputChannel "$nextOutputChannel"
    return $?
}

_nsoundUsage() {
    echo "Usage:"
    echo "$_nsoundExportAs"
    echo "    Settings for the sound."
    echo "[Options]"
    echo "    toggle"
    echo "        Toggles the sound output channel between available channels."
    echo "    <channel>"
    echo "        Sets sound output channel to provided channel."
    echo "    -c"
    echo "        Displays current output channel."
    echo "    -h"
    echo "        Shows this message."
}

_nsound() {
    local input="$1"

    if [[ "$input" == "toggle" ]]; then
        _nsoundToggleOutputChannel
        return $?
    fi

    if [[ "$input" == "-c" ]]; then
        _nsoundCurrentOutputChannel
        return $?
    fi

    if [[ "$input" == "-h" ]]; then
        _nsoundUsage
        return $?
    fi

    if [[ "$input" != "" ]]; then
        _nsoundSetOutputChannel "$input"
        return $?
    fi

    echo "[ERROR] Wrong usage!"
    _nsoundUsage
    return 1
}

_nsoundInit

alias $_nsoundExportAs="_nsound"

_nLog "Use '$_nsoundExportAs toggle' to toggle between available channels."
_nLog "Use '$_nsoundExportAs -h' to know more about this command."
