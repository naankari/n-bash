#!/bin/bash


# Environment
#   N_CONFIG_DIR
#        Required: True
#   N_AWS_ENV_CREDENTIALS_FILE_PREFIX
#       Required: False
#       Default Value: "$N_CONFIG_DIR/aws-env-credentials"
#   N_AWS_ENV_PROFILE_FILE_PREFIX
#       Required: False
#       Default Value: "$N_CONFIG_DIR/aws-env-profile"
#    N_AWS_ENV_EXPORT_AS
#        Required: False
#        Default Value: "awsEnv"


_nawsEnvCredentialsFilePrefix="$(_nAbsolutePath "${N_AWS_ENV_CREDENTIALS_FILE_PREFIX-$N_CONFIG_DIR/aws-env-credentials-}")"
_nawsEnvProfileFilePrefix="$(_nAbsolutePath "${N_AWS_ENV_PROFILE_FILE_PREFIX-$N_CONFIG_DIR/aws-env-profile-}")"
_nawsEnvExportAs="${N_AWS_ENV_EXPORT_AS-awsEnv}"

_nCredentialsFilePropertyNames=("aws_access_key_id" "aws_secret_access_key" "aws_session_token")
_nProfileFilePropertyNames=("aws_account_number" "aws_account_type" "aws_default_region" "aws_vpc_name" "aws_key_pair_name")

_nExportProperties() {
    local propertyNames=("$@")

    for propertyName in "${propertyNames[@]}"; do
        local envVariableName="$(_nToUpper "$propertyName")"
        local value="${!propertyName}"

        export $envVariableName="$value"

        _nLogOrEcho "$envVariableName=$value"
    done
}

_nawsEnvLoad() {
    local env="$1"

    if [[ "$env" == "" ]]; then
        env="default"
    fi

    local credentialsFile="$_nawsEnvCredentialsFilePrefix$env"
    local profileFile="$_nawsEnvProfileFilePrefix$env"

    _nSourceIf "$credentialsFile"
    _nSourceIf "$profileFile"

    _nExportProperties "${_nCredentialsFilePropertyNames[@]}"
    _nExportProperties "${_nProfileFilePropertyNames[@]}"
}

_nawsCopyCredentials() {
    local env="$1"
    local file="$2"

    if [[ ! -f $file ]]; then
        _nErrorOrEcho "Did not find $file to import."
        return 1
    fi

    local sourcePath="$(_nAbsolutePath "$file")"

    if [[ ! -f $sourcePath ]]; then
        _nErrorOrEcho "Did not find $file to import."
        return 1
    fi

    local destinationPath="$_nawsEnvCredentialsFilePrefix$env"

    cp "$sourcePath" "$destinationPath"

    _nLogOrEcho "Successfully copied credentials file $sourcePath to $destinationPath"
}

_nawsEnvPrintUsage() {
    echo "Usage:"
    echo "$_nawsEnvExportAs"
    echo "    Load aws environment."
    echo "[Options]"
    echo "    load <environment>"
    echo "        Load provided environment."
    echo "    copyCredentials <environment> <file>"
    echo "        Copy credentials file for given environment"
    echo "    -?"
    echo "        Show this message."
}

_nawsEnv() {
    local action="$1"

    if [[ "$action" == "-?" ]]; then
        _nawsEnvPrintUsage
        return $?
    fi

    if [[ "$action" == "load" ]]; then
        _nawsEnvLoad "$2"
        return $?
    fi

    if [[ "$action" == "copyCredentials" ]]; then
        _nawsCopyCredentials "$2" "$3"
        return $?
    fi

    _nawsEnvPrintUsage
    return 1
}

alias $_nawsEnvExportAs="_nawsEnv"

_nLog "Use '$_nawsEnvExportAs <env> to load aws environment."
_nLog "Use '$_nawsEnvExportAs -?' to know more about this command."
